#Использовать logos
// #Использовать progbar
#Использовать "../lib/cfe2cf"
#Использовать tempfiles


Перем ЭкспортироватьИсходникиИзФорматаЕДТ Экспорт;
Перем УдалятьИсходныеФайлыВФорматеКонфигуратора Экспорт;
Перем СборкаРасширения Экспорт;
Перем СборкаКонфигурации Экспорт;
Перем СборкаПортативная Экспорт;
Перем ВерсияЕДТ Экспорт;
Перем КаталогПлатформы Экспорт;

Перем Лог;
Перем МенеджерВременныхФайлов;
Перем КаталогСборки;
Перем КаталогРепозитория;
Перем КаталогИсходныхФайлов;
Перем ВременныйКаталогСборки;



Процедура ПодготовитьПустойКаталог(Каталог)
	Если ФС.Существует(Каталог) Тогда
		УдалитьФайлы(Каталог);
	КонецЕсли;
	
	ФС.ОбеспечитьКаталог(Каталог);
	
КонецПроцедуры

Процедура Инициализировать()
	Старт = СтартовыйСценарий();
	
	МассивИмениКаталога = СтрРазделить(Старт.Каталог, ПолучитьРазделительПути());
	МассивИмениКаталога.Удалить(МассивИмениКаталога.Количество() - 1);
	МассивИмениКаталога.Удалить(МассивИмениКаталога.Количество() - 1);
	
	КаталогРепозитория = СтрСоединить(МассивИмениКаталога, ПолучитьРазделительПути());
	КаталогСборки = ОбъединитьПути(КаталогРепозитория, "build");
	
	МенеджерВременныхФайлов = Новый МенеджерВременныхФайлов();
	МенеджерВременныхФайлов.БазовыйКаталог = ОбъединитьПути(КаталогСборки,"tmp");
	
	РабочийКаталогРИНГ = МенеджерВременныхФайлов.НовоеИмяФайла();
	
	Лог = Новый Лог("app.build.tools_ui_1c");
	Лог.УстановитьУровень(УровниЛога.Отладка);
	
	ЭкспортироватьИсходникиИзФорматаЕДТ=Истина;
	УдалятьИсходныеФайлыВФорматеКонфигуратора=Истина;
	СборкаРасширения=Истина;
	СборкаКонфигурации=Истина;
	СборкаПортативная=Истина;
КонецПроцедуры

Процедура ВыполнитьСборку() Экспорт
	ПередНачаломСборки();
	
	ПроектыДляКонвертации = Новый Массив();
	ПроектыДляКонвертации.Добавить("Инструменты");
	ПроектыДляКонвертации.Добавить("Портативный");
	
	//1. Конвертируем исходники в формат конфигуратора
	Если ЭкспортироватьИсходникиИзФорматаЕДТ Тогда
		Отказ = Ложь;
		
		Для Каждого ТекПроект Из ПроектыДляКонвертации Цикл
			КонвертерИсходников = Новый КонвертерИсходныхФайловВФорматКонфигуратора();
			КонвертерИсходников.ВерсияЕДТ=ВерсияЕДТ;
			КонвертерИсходников.УстановитьЛог(Лог);
			КонвертерИсходников.УстановитьКаталогИсходниковEDT(ОбъединитьПути(КаталогРепозитория,"src",ТекПроект));
			КонвертерИсходников.УстановитьКаталогРезультатаКонвертации(ОбъединитьПути(КаталогИсходныхФайлов, ТекПроект));
			Успешно = КонвертерИсходников.ВыполнитьКонвертацию();
			
			Если Не Успешно Тогда
				Лог.КритичнаяОшибка("Не удалось сконвертировать в формат конфигуратора проект " + ТекПроект);
				Отказ=Истина;
				Прервать;
			КонецЕсли;
			
		КонецЦикла;
		
		Если Отказ Тогда
			ПриЗавершенииСборки();
			Возврат;
		КонецЕсли;
	КонецЕсли;
	
	ВариантыСборкиРасширения = Новый Массив;
	ВариантыСборкиРасширения.Добавить(ВариантыСборки.БезТаблицБезБСП);
	ВариантыСборкиРасширения.Добавить(ВариантыСборки.СТаблицамиБезБСП);
	ВариантыСборкиРасширения.Добавить(ВариантыСборки.СТаблицамиСБСП);
	ВариантыСборкиРасширения.Добавить(ВариантыСборки.БезТаблицСБСП);
	
	КаталогСборкиПодВарианты = МенеджерВременныхФайлов.СоздатьКаталог();
	
	Для Каждого ВариантСборки ИЗ ВариантыСборкиРасширения Цикл
		КаталогФайловСконвертированногоРасширения = ОбъединитьПути(КаталогСборкиПодВарианты, ВариантСборки.Имя);
		
		ИмяФайлаВарианта = ВариантСборки.ИмяФайла;
		ИмяФайлаРасширения = ОбъединитьПути(КаталогСборки, ИмяФайлаВарианта + ".cfe");
		// ФС.ОбеспечитьКаталог(ОбъединитьПути(КаталогСборки, ВариантСборки.Имя));
		
		СборщикРасширения = Новый СборщикРасширения();
		СборщикРасширения.ВариантСборки = ВариантСборки;
		СборщикРасширения.УстановитьЛог(Лог);
		СборщикРасширения.УстановитьКаталогИсходныхФайлов(КаталогИсходныхФайлов);
		СборщикРасширения.УстановитьКаталогРезультатаСборки(КаталогФайловСконвертированногоРасширения);
		СборщикРасширения.ВыполнитьСборкуИсходников();
		Если СборкаРасширения Тогда
			Лог.Информация("Начинаю сборку расширения для варианта " + ВариантСборки.Имя);
			
			СборщикРасширения.ВыполнитьСозданиеБинарногоФайла(ИмяФайлаРасширения);
			
			Лог.Информация("Сборка в расширение завершена для варианта "+ ВариантСборки.Имя);
		КонецЕсли;
		
		Если СборкаКонфигурации Тогда
			Лог.Информация("Начинаю сборку конфигурации для варианта " + ВариантСборки.Имя);
			
			ИмяРасширения 			= "УниверсальныеИнструменты";
			ИмяФайлаКонфигурации 	= ОбъединитьПути(КаталогСборки, ИмяФайлаВарианта + ".cf");
			
			СборщикРасширения.ДобавитьИнформациюОСборкеВОбщийМодуль(Истина);

			Конвертор = Новый КонверторРасширений();
			Конвертор.ИсходныйПуть 				= КаталогФайловСконвертированногоРасширения;
			Конвертор.ИмяРасширения 			= ИмяРасширения;
			Конвертор.ИмяФайлаКонфигурации 		= ИмяФайлаКонфигурации;
			Конвертор.КаталогВременныхФайлов 	= МенеджерВременныхФайлов.СоздатьКаталог();
			Конвертор.ИмяКаталогаПлатформы		= КаталогПлатформы;
			Конвертор.ВыполнитьПреобразованиеИзИсходныхФайловРасширения();
			
			УдалитьФайлы(Конвертор.КаталогВременныхФайлов);
			
			Лог.Информация("Сборка конфигурации завершена для варианта " + ВариантСборки.Имя);
		КонецЕсли;
	КонецЦикла;
	Если СборкаПортативная Тогда
		Лог.Информация("Начало сборки портативной поставки");
		КаталогПортативнойСборки= ОбъединитьПути(КаталогСборки, "Портативная");

		Сборщик = Новый СборщикПортативнойПоставки(КаталогИсходныхФайлов);
		Сборщик.КаталогВременных = МенеджерВременныхФайлов.СоздатьКаталог();
		Сборщик.УстановитьЛог(Лог);
		Сборщик.ВыполнитьКонвертацию(КаталогПортативнойСборки);
		
		Лог.Информация("Завершение сборки портативной поставки");
	КонецЕсли;	
	УдалитьФайлы(КаталогСборкиПодВарианты);
	
	ПриЗавершенииСборки();
КонецПроцедуры

Процедура ПередНачаломСборки()
	// ПодготовитьПустойКаталог(КаталогСборки);
	
	ВременныйКаталогСборки = МенеджерВременныхФайлов.СоздатьКаталог();
	// ФС.ОбеспечитьКаталог(РабочийКаталогРИНГ);
	
	КаталогИсходныхФайлов = ОбъединитьПути(КаталогСборки, "source");
	Если ЭкспортироватьИсходникиИзФорматаЕДТ Тогда
		ПодготовитьПустойКаталог(КаталогИсходныхФайлов);
	КонецЕсли;
КонецПроцедуры

Процедура ПриЗавершенииСборки()
	МенеджерВременныхФайлов.Удалить();
	УдалитьФайлы(МенеджерВременныхФайлов.БазовыйКаталог);
	
	Если УдалятьИсходныеФайлыВФорматеКонфигуратора Тогда
		УдалитьФайлы(КаталогИсходныхФайлов);
	КонецЕсли;
	
КонецПроцедуры

Инициализировать();