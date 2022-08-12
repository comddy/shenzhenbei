# -*- coding: utf-8 -*-
# author:           inspurer(月小水长)
# create_time:      2022/01/17 10:31
# 运行环境           Python3.6+
# github            https://github.com/inspurer
# 微信公众号         月小水长

import json
import pandas as pd
limit = 100000
from time import sleep
config_path = 'topic_comment_config.json'
with open(config_path, 'r', encoding='utf-8-sig') as f:
    config_json = json.loads(f.read())
data_path = f'./topic/{config_json["keyword"]}.csv'
def drop_duplicate(path, col="mid"):
    df = pd.read_csv(path)
    # 去除重复行数据
    df.drop_duplicates(keep='first', inplace=True, subset=[col])
    # 可能还剩下重复 header
    df = df[-df[col].isin([col])]
    df.to_csv(path, encoding='utf-8-sig', index=False)

def main():
    drop_duplicate(data_path)

    df = pd.read_csv(data_path)

    # 清除原有的 comments 配置，如不需要可注释
    config_json['comments'].clear()

    for index, row in df.iterrows():
        print(f'{index + 1}/{df.shape[0]}')
        comment_num = row['comment_num']
        weibo_link = row['weibo_link']
        try:
            comment_num = int(comment_num)
        except:
            comment_num = 0
        if comment_num <= 0:
            print(f'\n\n {weibo_link} 没有评论，不加入配置 json \n\n')
            continue
        if '?' in weibo_link:
            weibo_link = weibo_link[:weibo_link.index('?')]
        uid = weibo_link[weibo_link.index('com') + 4:weibo_link.rindex('/')]
        mid = weibo_link[weibo_link.rindex('/') + 1:]
        config_json['comments'].append({
            'index': f'N{len(config_json["comments"])}',
            'mid': mid,
            'uid': uid,
            'limit': limit,
            'user_name': row['user_name']
        })

    config_json['comments_pos'] = 0

    print(f"\n\n\n 共计 {len(config_json['comments'])} 条微博加入评论抓取队列...  \n\n\n")
    sleep(3)

    with open(config_path, 'w', encoding='utf-8-sig') as f:
        f.write(json.dumps(config_json, indent=2, ensure_ascii=False))

if __name__ == '__main__':
    main()
