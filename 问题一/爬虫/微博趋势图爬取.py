import json
import re

import pandas as pd
import requests

header = {
    'cookie': "SINAGLOBAL=8747714352660.379.1647532449053; login_sid_t=72fda6fccc2a02a9bb0fe7b5e42c82f3; cross_origin_proto=SSL; wb_view_log=1536*8641.25; _s_tentry=www.bing.com; UOR=,,www.bing.com; Apache=1916465131241.174.1658916458075; ULV=1658916458079:2:1:1:1916465131241.174.1658916458075:1647532449060; XSRF-TOKEN=RRTbtTna7fYYbusvsHLHAVzJ; WBPSESS=kErNolfXeoisUDB3d9TFH0EiCBQJGp9Qorf5AHr9T9LSHeu0UCopV8bX76ESGpwqry6vnmfXWiugsEg4Pe7icEouZ8GY6ocfs_xiga7vBCTN09QZ7dGOPe8rDE5QfM7KCCCeIXeo-6OfRrzjdayFsMeah4jxJXCtLvvEnbi3Mz4=; PC_TOKEN=b7847bb34f; WBStorage=4d96c54e|undefined; SUB=_2A25P5VnADeRhGeBN41oU9C3IyD-IHXVsk8wIrDV8PUNbmtAKLXP8kW9NRAs-0Qn3A3ZMT8GHbsrWQyailcUP2e3q; SUBP=0033WrSXqPxfM725Ws9jqgMF55529P9D9WFv0rES1QMC9uG1H8aLckLr5JpX5KzhUgL.Foq01hnfSheXe0e2dJLoIp7LxKML1KBLBKnLxKqL1hnLBoMce0nRSKB0She0; ALF=1690459408; SSOLoginState=1658923408; wvr=6; wb_view_log_6388543433=1536*8641.25; webim_unReadCount=%7B%22time%22%3A1658923658072%2C%22dm_pub_total%22%3A0%2C%22chat_group_client%22%3A0%2C%22chat_group_notice%22%3A0%2C%22allcountNum%22%3A42%2C%22msgbox%22%3A0%7D"
}

url = input("请输入阅读趋势URL：")

html1 = requests.get(url,headers=header).text

find_url = re.compile(r'url=(.*?);(.*)?;"/>')

url2 = find_url.findall(html1)
print(url2[0][1])

html2 = requests.get(url2[0][1],headers=header).text

# print(html2)
a = json.loads(html2)

# a = {"code":"100000","msg":"success","data":{"read":[{"time":"07-04","value":355628},{"time":"07-05","value":267622},{"time":"07-06","value":584938},{"time":"07-07","value":452856},{"time":"07-08","value":486754},{"time":"07-09","value":294320},{"time":"07-10","value":297622},{"time":"07-11","value":459854},{"time":"07-12","value":393343},{"time":"07-13","value":195066},{"time":"07-14","value":171990},{"time":"07-15","value":172222},{"time":"07-16","value":191014},{"time":"07-17","value":129734},{"time":"07-18","value":134242},{"time":"07-19","value":197806},{"time":"07-20","value":264807},{"time":"07-21","value":126030},{"time":"07-22","value":119548},{"time":"07-23","value":393877},{"time":"07-24","value":109870},{"time":"07-25","value":181120},{"time":"07-26","value":64866},{"time":"07-27","value":82110},{"time":"07-28","value":83390},{"time":"07-29","value":72402},{"time":"07-30","value":70654},{"time":"07-31","value":57294},{"time":"08-01","value":49226},{"time":"08-02","value":49678}]}}

read_trend=[]
read_trend_value=[]
for i in a:
    if i=="data":
        for j in a[i]:

            for t in a[i][j]:

                read_trend.append(t["time"])
                read_trend_value.append(int(t['value']))

print("阅读趋势",read_trend)
print("阅读趋势value",read_trend_value)



url = input("请输入讨论趋势URL")

html1 = requests.get(url,headers=header).text

find_url = re.compile(r'url=(.*?);(.*)?;"/>')

url2 = find_url.findall(html1)
print(url2[0][1])

html2 = requests.get(url2[0][1],headers=header).text

# print(html2)
a = json.loads(html2)

# a = {"code":"100000","msg":"success","data":{"read":[{"time":"07-04","value":355628},{"time":"07-05","value":267622},{"time":"07-06","value":584938},{"time":"07-07","value":452856},{"time":"07-08","value":486754},{"time":"07-09","value":294320},{"time":"07-10","value":297622},{"time":"07-11","value":459854},{"time":"07-12","value":393343},{"time":"07-13","value":195066},{"time":"07-14","value":171990},{"time":"07-15","value":172222},{"time":"07-16","value":191014},{"time":"07-17","value":129734},{"time":"07-18","value":134242},{"time":"07-19","value":197806},{"time":"07-20","value":264807},{"time":"07-21","value":126030},{"time":"07-22","value":119548},{"time":"07-23","value":393877},{"time":"07-24","value":109870},{"time":"07-25","value":181120},{"time":"07-26","value":64866},{"time":"07-27","value":82110},{"time":"07-28","value":83390},{"time":"07-29","value":72402},{"time":"07-30","value":70654},{"time":"07-31","value":57294},{"time":"08-01","value":49226},{"time":"08-02","value":49678}]}}

talk_trend=[]
talk_trend_value=[]
for i in a:
    if i=="data":
        for j in a[i]:

            for t in a[i][j]:
                talk_trend.append(t["time"])
                talk_trend_value.append(int(t['value']))

print("讨论趋势",talk_trend)
print("讨论趋势value",talk_trend_value)


url = input("请输入原创人数趋势URL")

html1 = requests.get(url,headers=header).text

find_url = re.compile(r'url=(.*?);(.*)?;"/>')

url2 = find_url.findall(html1)
print(url2[0][1])

html2 = requests.get(url2[0][1],headers=header).text

# print(html2)
a = json.loads(html2)

# a = {"code":"100000","msg":"success","data":{"read":[{"time":"07-04","value":355628},{"time":"07-05","value":267622},{"time":"07-06","value":584938},{"time":"07-07","value":452856},{"time":"07-08","value":486754},{"time":"07-09","value":294320},{"time":"07-10","value":297622},{"time":"07-11","value":459854},{"time":"07-12","value":393343},{"time":"07-13","value":195066},{"time":"07-14","value":171990},{"time":"07-15","value":172222},{"time":"07-16","value":191014},{"time":"07-17","value":129734},{"time":"07-18","value":134242},{"time":"07-19","value":197806},{"time":"07-20","value":264807},{"time":"07-21","value":126030},{"time":"07-22","value":119548},{"time":"07-23","value":393877},{"time":"07-24","value":109870},{"time":"07-25","value":181120},{"time":"07-26","value":64866},{"time":"07-27","value":82110},{"time":"07-28","value":83390},{"time":"07-29","value":72402},{"time":"07-30","value":70654},{"time":"07-31","value":57294},{"time":"08-01","value":49226},{"time":"08-02","value":49678}]}}

create_trend=[]
create_trend_value=[]
for i in a:
    if i=="data":
        for j in a[i]:

            for t in a[i][j]:
                create_trend.append(t["time"])
                create_trend_value.append(int(t['value']))

print("原创人数趋势", create_trend)
print("原创人数趋势value", create_trend_value)







print("阅读趋势",read_trend)
print("阅读趋势value",read_trend_value)

print("讨论趋势",talk_trend)
print("讨论趋势value",talk_trend_value)

print("原创人数趋势", create_trend)
print("原创人数趋势value", create_trend_value)


# df = pd.DataFrame(columns=["河南红码_阅读趋势x轴","河南红码_阅读趋势y轴","河南红码_讨论趋势x轴","河南红码_讨论趋势y轴","河南红码_原创人数x轴","河南红码_原创人数y轴"])
# df["河南红码_阅读趋势x轴"]=read_trend
# df["河南红码_阅读趋势y轴"]=read_trend_value
# df["河南红码_讨论趋势x轴"]=talk_trend
# df["河南红码_讨论趋势y轴"]=talk_trend_value
# df["河南红码_原创人数x轴"]=create_trend
# df["河南红码_原创人数y轴"]=create_trend_value
df = pd.read_excel("30_days_data.xlsx")
df["二舅治好了我的精神内耗_阅读趋势x轴"]=read_trend
df["二舅治好了我的精神内耗_阅读趋势y轴"]=read_trend_value
df["二舅治好了我的精神内耗_讨论趋势x轴"]=talk_trend
df["二舅治好了我的精神内耗_讨论趋势y轴"]=talk_trend_value
df["二舅治好了我的精神内耗_原创人数x轴"]=create_trend
df["二舅治好了我的精神内耗_原创人数y轴"]=create_trend_value




df.to_excel("30_days_data.xlsx",index=None)









