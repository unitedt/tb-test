# Test task for Talkbank.io

1. Если мы используем *Symfony* - логично использовать API Platform, предназначенный для создания REST API сервисов. Как
вариант можно использовать FOSRestBundle, но, по моему, это более ограниченное решение в контексте того, если мы 
планируем расширять сервис в дальнейшем.

2. По структуре приложения - скорее всего, мы не будем использовать Doctrine ORM (только Doctrine DBAL) так как его 
сложность здесь избыточна. Работу с базой данных построим на основе паттернов DAO/DTO. Работу с эндпойнтами организуем
на основе Custom Controllers API Platform, валидировать входные DTO будем с помощью Symfony\Component\Validator. 

3. Желательно использовать такие коды промокодов, которые можно перекодировать в 64 битный int. Для буквенно-цифрового 
кода это будет максимально log₆₂(2^(64-1)) ~ 11 символов, что отвечает требованию "должен быть недлинным". Причина - 
операции с числами выполняются и быстрее, и они занимают меньше памяти. Данного диапазона должно хватить и для множества 
уникальных промокодов для уникальных пользователей, и для исключения подбора промокодов брут-форсом.

4. id промокода - это может быть и сам код промокода, перекодированный в int. Но, представляется, что это не самый 
лучший вариант - т.к. у нас в требованиях есть то, что в будущем возможны другие форматы (которые могут и не 
укладываться в 64 битный int). Кроме этого, рандомный int в качестве первичного ключа вызывает разброс значений таблицы, 
что не есть, в общем-то, хорошо. Поэтому наш выбор - суррогатный ключ SERIAL либо же монотонно возрастающий UUID v6  
(см. библиотеку https://uuid.ramsey.dev/en/latest/nonstandard/version6.html).

5. Структура базы данных. С заделом на расширение можно предложить две таблицы:

~~~
CREATE TABLE public.promocodes
(
    id BIGSERIAL PRIMARY KEY,
    discount DECIMAL(5,2) NOT NULL,
    maxUseCount INT DEFAULT 0 NOT NULL,
    useCount INT DEFAULT 0 NOT NULL
);

CREATE TABLE public.promocodes_codes
(
    code BIGINT NOT NULL PRIMARY KEY,
    id BIGINT,
    CONSTRAINT promocodes_codes_promocodes_id_fk FOREIGN KEY (id) REFERENCES promocodes (id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE UNIQUE INDEX promocodes_codes_code_uindex ON public.promocodes_codes (code);
~~~

однако подойдёт и вариант с одной таблицей (если мы принимаем то, что code - это уникальный идентификатор промокода, 
один промокод не может иметь и цифровое, и буквенно-цифровое представление):

~~~
CREATE TABLE public.promocodes
(
    id BIGSERIAL PRIMARY KEY,
    code BIGINT NOT NULL,
    discount DECIMAL(5,2) NOT NULL,
    maxUseCount INT DEFAULT 0 NOT NULL,
    useCount INT DEFAULT 0 NOT NULL
);

CREATE UNIQUE INDEX promocodes_code_uindex ON public.promocodes (code);
~~~

6. Redis можно задействовать в качестве механизма (слоя) кэширования. Сохранять в нём (в хэш-таблицах) соответствие 
кода промокода и id промокода, таким образом уменьшаем запросы в SQL-базу.  
Можно записывать промокод в кэш и при генерации, но тут вопрос - если необходимо генерировать большое количество 
промокодов (регулярно раздаём всем покупателям уникальные), а де-факто будут использовано только небольшое количество, 
то мы зря будет расходовать оперативную память на кэш неиспользуемых кодов. Также для каждого кода разумно хранить 
признак недействительности промокода, чтобы отсечь от базы запросы к уже недействительным кодам. В случае промаха кэша, 
информацию, само собой, подтягиваем из основной базы. Нюанс: используем числовые имена ключей хэша (перекодированный 
код промокода) и множество хэш-таблиц при хранении большого количества (от миллиона) записей (например по 500 записей в 
таблицу).

7. API описал в исполняемых спецификациях на языке *Gherkin* - [./features](./features)