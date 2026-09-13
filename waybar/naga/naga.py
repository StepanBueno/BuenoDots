import requests
import json

# Параметры запроса
params = {'hero_id': '136'}
response = requests.get('https://api.opendota.com/api/players/934740280/heroes', params=params)

#реквестим полученные данные с нашими параметрами в виде json и задаём нашему hero_data тильки нагу т.к 1 элементом становится именно она из-за заданных параметров
response_json = response.json()
hero_data = response_json[0]

#ну а теперь просто выводим все нужные о ней данные и делаем рассчёт винрейта
print("Ｐｌａｙｅｒ: Ｓｔｅｐａｎ Ｂｕｅｎｏ")
print("Ｎａｍｅ: Ｍａｒｃｉ")
print(f"ＩＤ: {hero_data.get('hero_id')}")
print(f"Ｍａｔｃｈｅｓ: {hero_data.get('games')}")
gamesi = hero_data.get('games')
pobedisi = hero_data.get('win')
winratek = pobedisi/gamesi
winrate = round(winratek * 100, ndigits=2)
print('Ｗｉｎｒａｔｅ:', winrate, '%')


