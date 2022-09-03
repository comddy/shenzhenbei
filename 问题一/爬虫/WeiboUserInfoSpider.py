# -*- coding: utf-8 -*-
# author:           inspurer(月小水长)
# create_time:      2021/9/3 21:01
# 运行环境           Python3.6+
# github            https://github.com/inspurer
# 微信公众号         月小水长
import random
import time

import requests

import pandas as pd

from time import sleep

import json

headers = {
    'authority': 'weibo.com',
    'x-requested-with': 'XMLHttpRequest',
    'sec-ch-ua-mobile': '?0',
    'user-agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    'content-type': 'application/x-www-form-urlencoded',
    'accept': '*/*',
    'sec-fetch-site': 'same-origin',
    'sec-fetch-mode': 'cors',
    'sec-fetch-dest': 'empty',
    'referer': 'https://weibo.com/1192329374/KnnG78Yf3?filter=hot&root_comment_id=0&type=comment',
    'accept-language': 'zh-CN,zh;q=0.9,en-CN;q=0.8,en;q=0.7,es-MX;q=0.6,es;q=0.5',
    'cookie': 'SINAGLOBAL=8747714352660.379.1647532449053; UOR=,,login.sina.com.cn; SUBP=0033WrSXqPxfM725Ws9jqgMF55529P9D9WFv0rES1QMC9uG1H8aLckLr5JpX5KMhUgL.Foq01hnfSheXe0e2dJLoIp7LxKML1KBLBKnLxKqL1hnLBoMce0nRSKB0She0; PC_TOKEN=ddd55c325f; ALF=1691510755; SSOLoginState=1659974756; SCF=AhAscXZ1ekUo6NTIOCiotBiqll1uZHwGtrMoC5AnYbegBHAumPXReLX3hk3MIngecCyMEx4u-dAWYH0VeTo_d0Y.; SUB=_2A25P9UQ0DeRhGeBN41oU9C3IyD-IHXVsgzL8rDV8PUNbmtANLRn2kW9NRAs-0T8pnCTW9KPG6DrKapUqANAP5Vru; _s_tentry=weibo.com; Apache=3905072564128.9175.1659974769817; ULV=1659974769896:15:10:2:3905072564128.9175.1659974769817:1659841862898'}


def parseUid(uid):
    response = requests.get(url=f'https://weibo.com/ajax/profile/info?custom={uid}', headers=headers)
    print(response.json())
    try:
        return response.json()['data']['user']['id']
    #
    except:
        return None


def getUserInfo(uid):
    try:
        uid = int(uid)
    except:
        # 说明是 xiena 这样的英文串
        uid = parseUid(uid)
        if not uid:
            return None
    response = requests.get(url=f'https://weibo.com/ajax/profile/detail?uid={uid}', headers=headers)
    # print(response.text)
    if response.status_code == 400:
        return {
            'errorMsg': '用户可能注销或者封号',
            'location': None,
            'user_link': f'https://weibo.com/{uid}'
        }
    resp_json = response.json().get('data', None)
    if not resp_json:
        return None
    sunshine_credit = resp_json.get('sunshine_credit', None)
    if sunshine_credit:
        sunshine_credit_level = sunshine_credit.get('level', None)
    else:
        sunshine_credit_level = None
    education = resp_json.get('education', None)
    if education:
        school = education.get('school', None)
    else:
        school = None

    location = resp_json.get('location', None)
    gender = resp_json.get('gender', None)

    birthday = resp_json.get('birthday', None)
    created_at = resp_json.get('created_at', None)
    description = resp_json.get('description', None)
    # 我关注的人中有多少人关注 ta
    followers = resp_json.get('followers', None)
    if followers:
        followers_num = followers.get('total_number', None)
    else:
        followers_num = None
    return {
        'sunshine_credit_level': sunshine_credit_level,
        'school': school,
        'location': location,
        'gender': gender,
        'birthday': birthday,
        'created_at': created_at,
        'description': description,
        'followers_num': followers_num
    }

'''
给 df 加 user_info
'''


def dfAddUserInfo(file_path, user_col, user_info_col='user_info'):
    '''
    @params file_path 指定路径
    @params user_col 指定用户主页链接在那一列, 比如评论csv文件的是 comment_user_link
    @params user_info_col 指定新加的 userinfo 列名，默认是 user_info
    '''
    df = pd.read_csv(file_path)
    user_info_init_value = 'init'
    columns = df.columns.values.tolist()
    if not user_info_col in columns:
        df[user_info_col] = [user_info_init_value for _ in range(df.shape[0])]
    for index, row in df.iterrows():
        print(f'   {index+1}/{df.shape[0]}   ')
        if (index+1) % 100 == 0:
            df.to_csv(file_path, index=False, encoding='utf-8-sig')
        if not row.get(user_info_col, user_info_init_value) == user_info_init_value:
            print('skip')
            continue
        user_link = row[user_col]
        user_link = user_link[:user_link.rindex('?')]
        user_id = user_link[user_link.rindex('/')+1:]
        user_info = getUserInfo(user_id)
        print(user_info)
        if user_info:
            # 在 user_info 中统一为 user_link
            user_info['user_link'] = user_link
            df.loc[index, user_info_col] = json.dumps(user_info, ensure_ascii=False)
            sleep(1)
        else:
            print(user_link)
            break
        df.to_csv(file_path, index=False, encoding='utf-8-sig')

'''
从已经加好 userinfo 的 df 里遍历 userinfo 
'''
def dfGetUserInfo(file_path, user_info_col):
    df = pd.read_csv(file_path)
    for index, row in df.iterrows():
        user_info = json.loads(row[user_info_col])
        location = user_info['location']
        user_link = user_info['user_link']

        print(location, user_link)


def get_uidlist(name):
    df = pd.read_excel(name)
    uid_list = []
    try:
        for u in df["uid"]:
            uid_list.append(u)
        return {
            "uid":uid_list,
            "username":df["comment_user_name"]
        }

    except:
        print("出错了！！！！！！")
        return None

#获取指定uid用户的粉丝数
def get_fans(uid):
    url="https://weibo.com/ajax/profile/info?custom={0}".format(uid)
    try:
        reqe = requests.get(url, headers=headers)
        print(reqe.text)
        #粉丝数
        followers = reqe.json()["data"]["user"]["followers_count"]
        #关注数
        focus = reqe.json()["data"]["user"]["friends_count"]
        return {
            'followers':followers,
            'focus':focus
        }
    except:
        #请求错误就返回None
        return None



if __name__ == '__main__':
    excel_list=["./clear_data/clear_data_二舅治好了我的精神内耗.xlsx"]
    #,"","唐山打人事件.xlsx","东航失事.xlsx","河南村镇银行多位储户又被赋红码.xlsx","结婚16年3孩均非亲生事件.xlsx"
    uid = []
    uname = []
    follwers = []
    focus = []
    count =0
    now_count = 0
    for e in excel_list:
        #打开文件
        data= get_uidlist(e)
        uid_list, username_list = data["uid"],data["username"]
        #将读到的文件的用户名和uid添加到列表
        for u in uid_list:
            uid.append(u)
        print(uid)
        for un in username_list:
            uname.append(un)
        print(uname)
        #对每个文件进行遍历
        for ui in data["uid"]:

            # user_info = getUserInfo(uid=uid)
            #
            # print(user_info)
            ord = get_fans(uid=ui)
            if ord !=None:
                follwers.append(ord["followers"])
                focus.append(ord["focus"])
                # print(focus)
                #设置一个睡眠时间防止爬取过快
                if count>=5:
                    # time.sleep(random.randint(0, 1))
                    count=0
                else:
                    count+=1
                now_count += 1
            else:
                #如果该用户请求信息失败，就把uid和follwers中该用户元素删除
                print("现在的uid是",uid)
                print("现在的follwers是", follwers)
                print("现在的new_count是",now_count)
                uid.pop(now_count)
                uname.pop(now_count)



    print(uid)
    print("-----------------------------------------")
    print(uname)
    print("-----------------------------------------")
    print(follwers)
    print("-----------------------------------------")
    print(focus)
    print("-----------------------------------------")

    df  = pd.DataFrame()
    df["comment_user_name"] =uname
    df["uid"] =uid
    df["fans"] =follwers
    df["foucs_on"] =focus

    df.to_excel("My uncle_fans_and_foucs_on_data.xlsx",index=None)


    # uid ="1764201374"
    # user_info = getUserInfo(uid=uid)
    # print(user_info)
    # #获取指定uid的粉丝数
    # print(get_fans(uid=uid))

    # print(dfAddUserInfo(file_path='new_csv\\KnnG78Yf3.csv', user_col='comment_user_link'))
    # dfGetUserInfo(file_path='new_csv\\KnnG78Yf3.csv', user_info_col='user_info')