import os
import re

import numpy as np
import pandas as pd
# pd.set_option('max_rows',50000)
pd.set_option('max_columns',20)



print(os.getcwd())
os.chdir("C:\\Users\\橙子\\Desktop\\comment\\comment\\唐山打人事件")

topic_url = "C:\\Users\\橙子\\Desktop\\comment\\comment\\topic\\#唐山打人事件#.csv"
csv_list = os.listdir()
count = 1
df_compare = pd.read_csv(topic_url)
print(df_compare)
for i in range(len(df_compare)):
    print(df_compare.iat[i, 0])
    print(df_compare.iat[i,2])
global df
for k in csv_list:
    try:
        if k.split(".")[1]=="csv":
            df = pd.read_csv(k)
            topic_name = ""
            topic_mid = 0
            parent = []
            # 从微博信息中找到发该微博的用户名和mid
            for i in range(len(df_compare)):
                if k.split(".")[0] == str(df_compare.iat[i, 0]):
                    topic_name = df_compare.iat[i, 2]
                    topic_mid = df_compare.iat[i, 0]
                    # 结束这一层循环
                    break
            for d in range(len(df)):

                if str(df.iat[d,0])!="nan":
                    parent.append("")
                else:
                    df.iat[d, 0] = topic_mid
                    # 添加微博发布者
                    parent.append(topic_name)

            # 一次循环结束后在df文件里面加上一列
            df["parent_name"] = parent
            break

    except Exception as e:
        count+=1
print(df)

i=1
for l in csv_list:
    if len(l.split("."))>=2:
        if l.split(".")[1]=="csv" and i != count:
            topic_name = ""
            topic_mid = 0
            parent1 = []
            df1 = pd.read_csv(l)

            #从微博信息中找到发该微博的用户名和mid
            for i in range(len(df_compare)):
                if l.split(".")[0]==str(df_compare.iat[i, 0]):

                    topic_name=df_compare.iat[i,2]
                    # print(df_compare.iat[i, 2])
                    topic_mid = df_compare.iat[i, 0]
                    #结束这一层循环
                    break
            for d in range(len(df1)):
                if str(df1.iat[d,0])!="nan":
                    parent1.append("")
                else:
                    df1.iat[d, 0] = topic_mid
                    #添加微博发布者
                    parent1.append(topic_name)

            #一次循环结束后在df文件里面加上一列
            # print("开始剪切数据")
            df1["parent_name"] = parent1
            # print(df1)
            df = pd.concat([df,df1],axis=0)
            # print("合并后的df:",df)

        i+=1
    # except Exception as e:
    #     # print("报错了！！！")
    #     print('错误明细是', e.__class__.__name__, e)  # continue#jia
    #     continue
print(len(df))

new_df = pd.DataFrame(df)
# print(df)
tran_month={
    "Jul":7,
"Aug":8,
"Sept":9,
"Oct":10,
"Nov":11,
"Dec":12,
"Jun":6,
"Jan":1,
"Feb":2,
"Mar":3,
"Apr":4,
"May":5}


delte_a = re.compile(r'回复<a(.*?)</a>:')
delte_a1 = re.compile(r'回复 <a href=(.*?)</a>:')
delte_img = re.compile(r'<img(.*?)" />')
delte_img2 = re.compile(r'<img(.*)?/>')
no_reply_a = re.compile(r'<a href=(.*?)</a>')
#回复某人
reply_to_someone = re.compile(r'回复(.*)?@')


datalist=[]
for i in range(len(df)):
    Time = df.iat[i,2]
    y,m,d,h = Time.split(" ")[5].replace(" ",""),Time.split(" ")[1].replace(" ",""),Time.split(" ")[2].replace(" ",""),Time.split(" ")[3].split(":")[0].replace(" ","")
    for t in tran_month:
        if m==t:
            m = str(tran_month[t])
    new_time = y + "-" + m + "-" + d+ " " + h
    df.iat[i,2] = new_time
    print("df.iat[i,5]是",df.iat[i,5])

    content = str(df.iat[i,5])
    # print(content)
    # print(type(content))









    # print("matching_delete_a是"+str(matching_delete_a))





    # print("matching_delete_img是"+str(matching_delte_img))


    #把冗余信息处理掉
    New_content = str(content)

    # 正则表达式匹配到A标签和图片
    try:
        matching_delete_a = delte_a.findall(New_content)[0]

        matching_delete_a = "回复<a href=" + matching_delete_a + "</a>:"
    except:
        matching_delete_a = 0
    # print("matching_delete_a是"+str(matching_delete_a))

    if matching_delete_a != 0:
        New_content = New_content.replace(matching_delete_a,"")






    try:
        matching_delete_a1 = delte_a1.findall(New_content)[0]
        #网页形式不一致，有的回复后面加了个空格号
        matching_delete_a1 = "回复 <a href="+matching_delete_a1+"</a>:"
    except:
        matching_delete_a1 = 0
    # print("matching_delete_a是"+str(matching_delete_a))
    if matching_delete_a1 != 0:
        New_content = New_content.replace(matching_delete_a1,"")




    try:
        matching_delte_img = delte_img.findall(New_content)
        # 如果有多个表情发出，则一一匹配删除
        if len(matching_delte_img) > 1:
            for i in range(len(matching_delte_img)):
                matching_delte_img[i] = "<img" + matching_delte_img[i] + '" />'
        else:
            matching_delte_img = "<img" + matching_delte_img[0] + '" />'
    except:
        matching_delte_img = 0



    if matching_delte_img != 0:
        if len(matching_delte_img) >1:
            for i in range(len(matching_delte_img)):
                New_content =New_content.replace(matching_delte_img[i], "")
        else:
            New_content = New_content.replace(matching_delte_img, "")




        # 有的img图片确实"后面缺少空格
    try:
        matching_delte_img2 = delte_img2.findall(New_content)
        # 如果有多个表情发出，则一一匹配删除
        if len(matching_delte_img2) > 1:
            for i in range(len(matching_delte_img2)):
                matching_delte_img2[i] = "<img" + matching_delte_img2[i] + '"/>'
        else:
            matching_delte_img2 = "<img" + matching_delte_img2[0] + '"/>'
    except:
        matching_delte_img2 = 0

    if matching_delte_img2 != 0:
        if len(matching_delte_img2) >1:
            for i in range(len(matching_delte_img2)):
                New_content =New_content.replace(matching_delte_img2[i], "")
        else:
            New_content = New_content.replace(matching_delte_img2, "")




    try:
        no_reply = no_reply_a.findall(New_content)
        #网页形式不一致，有的回复后面加了个空格号
        if len(no_reply) > 1:
            for i in range(len(no_reply)):
                no_reply[i] = "<a href=" + no_reply[i] + '</a>'
        else:
            no_reply[0] = "<a href="+no_reply[0]+"</a>"
    except:
        no_reply = 0
    # print("matching_delete_a是"+str(matching_delete_a))
    if no_reply != 0:
        if len(no_reply) >1:
            for i in range(len(no_reply)):
                New_content =New_content.replace(no_reply[i], "")
        else:
            New_content = New_content.replace(no_reply[0], "")





    try:
        rts = reply_to_someone.findall(New_content)

        # 网页形式不一致，有的回复后面加了个空格号
        if len(rts) > 1:
            for i in range(len(rts)):
                rts[i] = "回复" + rts[i] + '@' + rts[i]
        else:
            rts[0] = "回复" + rts[0] + "@" + rts[0]
    except:
        rts = 0
    # print("rts is ", rts)

    if rts != 0:
        if len(rts) > 1:
            for i in range(len(rts)):
                New_content = New_content.replace(rts[i], "")
        else:
            New_content = New_content.replace(rts[0], "")




    # print("原生评论是",df.iat[i,5])
    print("消掉之后的评论是:",New_content.replace("回复:",""))
    datalist.append(New_content.replace("回复:","").replace("：",""))
    df.iat[i,5] = New_content
    # print(df.iat[i,5])


# 表情剔除
emoji = {"1":"🌴","2":"🌅","3":"🌴","4":"💖","5":"🍅","6":"🍓","7":"🍎","8":"🌺","9":"🤯",
         "10":"🙏","11":"👌","12":"👍","13":"👋","14":"😤","15":"🔪"
         ,"16":"👏","17":"🙂","18":"🐺","19":"😱","20":"🥺","21":"😡","22":"🤢"
         ,"23":"🤮","24":"🙉‍","25":"💨","26":"😰","27":"😔"
         ,"28":"💩","29":"‼️","30":"😣","31":"😢","32":"😯","33":"😅"
         ,"34":"🆙","35":"🙅","36":"🌻","37":"💰","38":"☔️","39":"🌂"
         ,"40":"🐶","41":"☂️","42":"👀","43":"❓","44":"🤗","45":"😿","47":"😲"
         ,"48":"👻","49":"👏","50":"😡","51":"👮‍♀️","52":"❌","53":"//:   ","54":"🙊","55":"🙏"
         ,"56":"😍","57":"🆘","58":"😅","59":"😨","60":"💪","61":"❌","62":"🥬","63":"🐎"
         ,"64":"🐮","65":"⚡","66":"🌞","67":"👍","68":"🐎","69":"🍐","70":"😢","71":"😳"
         ,"72":"😨","73":"😱","74":"😮","75":"‍💨","76":"🙃","77":"👿","78":"🔧","79":"🐯","80":"🐦"
         ,"81":"😂","82":"😄","83":"🚥","84":"💩","85":"🤗","86":"㊙️","87":"🉐","88":"🍺","89":"😳"
         ,"90":"🍉","92":"😫","93":"🍋","94":"🤓","95":"🕳","96":"⏬","97":"🍜","98":"🤣","99":"🍇"
         ,"100":"😬","101":"🏻","102":"👨","103":"🍗","104":"👊","105":"⭕️","106":"🤷‍♀️","107":"🍇","108":"🍇"}

#for循环消除无用表情
for i in range(len(datalist)):
    for j in emoji:
        datalist[i] = datalist[i].replace(emoji[j],"")


df = df.drop(["comment_content"],axis=1)

df["comment_content"] = datalist



# print(df["comment_content"])
# print(len(df))

df.reset_index(drop=True,inplace=True)
for i in range(len(df)):
    # print("第七行数据:",df["comment_content"][i])
    # print(len(df["comment_content"][i]))
    # print(type(df["comment_content"][i]))
    # print(i)
    try:
        if len(df["comment_content"][i].replace(" ",""))==0:
            df = df.drop(labels=i)
        elif len(df["comment_content"][i]) <= 2:
            df = df.drop(labels=i)
    except:
        continue

# df = pd.read_excel("河南村镇银行多位储户又被赋红码.xlsx")
# print(df["comment_user_link"])
uid_list=[]
for i in df["comment_user_link"]:
    uid = i.split("u/")[1]
    uid_list.append(uid)
    # print(uid)
df["uid"] = uid_list
# print(df)
# df.to_excel("C:\\Users\\橙子\\Desktop\\comment\\河南村镇银行多位储户又被赋红码.xlsx",index=None)
print(df["parent_name"])
df.to_excel("C:\\Users\\橙子\\Desktop\\comment\\唐山打人事件（改）.xlsx",index=None)

