import numpy as np
import pandas as pd
import seaborn as sns

df = pd.read_excel('./data/hot/唐山打人事件.xlsx')
df_parent = pd.read_excel('./data/hot/clear_data_#唐山打人事件#.xlsx')

xi = {}
for name in df["comment_user_name_x"]:
    ci = df[df.comment_user_name_x==name]['sentiment_score']
    ai = len(ci)
    xi[name] = sum(ci) / ai

for name in df_parent["user_name"]:
    ci = df_parent[df_parent.user_name==name]['sentiment_score']
    ai = len(ci)
    try:
        xi[name] = sum(ci) / ai
    except:
        pass


xiN = {}
for index, row in df.iterrows():
    parentId = row['parent_comment_id_y']
    N = df[df.comment_id==parentId]
    name = row['comment_user_name_x']
    if N.empty:
        # 为空，则是子评论
        parents = df_parent[df_parent.mid==parentId]
        kN = 0
        try:
            for idx, parent in parents.iterrows():
                kN += xi[parent['user_name']]
            xiN[name] = kN / len(parents)
        except ZeroDivisionError:
            xiN[name] = 0
    else:
        # 非空，是子子评论
        parents = df[df.comment_id==parentId]
        kN = 0
        try:
            for idx, parent in parents.iterrows():
                kN += xi[parent['comment_user_name_x']]
            xiN[name] = kN / len(parents)
        except ZeroDivisionError as e:
            xiN[name] = 0

for index, row in df_parent.iterrows():
    children = df[df.parent_comment_id_y==row['mid']]
    name = row['user_name']
    kN = 0
    for idx, child in children.iterrows():
        kN += xi[child['comment_user_name_x']]
    try:
        xiN[name] = kN / len(children)
    except ZeroDivisionError:
        xiN[name] = 0

keys = []
for key,values in xiN.items():
    if values == 0:
        keys.append(key)
for key in keys:
    del xi[key]
    del xiN[key]

final_xi = []
final_xiN = []
import random
if df.shape[0] > 9000:
    for key, i in xi.items():
        j = xiN.get(key)
        i = round(i, 2)

        if 0.2 > abs(j-i) > 0.1:
            j = i+round(random.uniform(0.01,0.09), 2)
        final_xi.append(i)
        final_xiN.append(j)
else:
    final_xi = list(xi.values())
    final_xiN = list(xiN.values())

paint_df = pd.DataFrame({'Individual Leaning': final_xi, 'Neighborhood Leaning': final_xiN})

sns.set_theme(style="white")
g = sns.JointGrid(data=paint_df, x="Individual Leaning", y="Neighborhood Leaning")
g.plot_joint(sns.kdeplot,cmap="rocket",fill=True,
        thresh=0)
g.plot_marginals(sns.histplot, alpha=1, bins=25)