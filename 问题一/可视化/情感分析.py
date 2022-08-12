from snownlp import SnowNLP
import pandas as pd
import json
from tencentcloud.common import credential
from tencentcloud.common.profile.client_profile import ClientProfile
from tencentcloud.common.profile.http_profile import HttpProfile
from tencentcloud.common.exception.tencent_cloud_sdk_exception import TencentCloudSDKException
from tencentcloud.nlp.v20190408 import nlp_client, models

def sentiment(text):
	try:
	    # 实例化一个认证对象，入参需要传入腾讯云账户secretId，secretKey,此处还需注意密钥对的保密
	    # 密钥可前往https://console.cloud.tencent.com/cam/capi网站进行获取

	    cred = credential.Credential("AKIDRhkY7WhdLsBG6lGZdUGpALL9qLchZGkB", "GH5g3A1f8ORGtJUQK1Vs44rPingMo47v")
	    # 实例化一个http选项，可选的，没有特殊需求可以跳过
	    httpProfile = HttpProfile()
	    httpProfile.endpoint = "nlp.tencentcloudapi.com"

	    # 实例化一个client选项，可选的，没有特殊需求可以跳过
	    clientProfile = ClientProfile()
	    clientProfile.httpProfile = httpProfile
	    # 实例化要请求产品的client对象,clientProfile是可选的
	    client = nlp_client.NlpClient(cred, 'ap-guangzhou', clientProfile)

	    # 实例化一个请求对象,每个接口都会对应一个request对象
	    req = models.SentimentAnalysisRequest()
	    params = {
	        "Version": '2019-04-08',
	        "Action": 'SentimentAnalysis',
	        'Region': 'ap-guangzhou',
	        'Text': text
	    }
	    req.from_json_string(json.dumps(params))

	    # 返回的resp是一个SentimentAnalysisResponse的实例，与请求对象对应
	    resp = client.SentimentAnalysis(req)
	    # 输出json格式的字符串回包
	    print(resp.to_json_string())
	    return resp.to_json_string()

	except TencentCloudSDKException as err:
	    print(err)
	except TypeError as err:
		return '{"Positive: 0.5", "Sentiment": "Neutral"}' 

name = "二舅治好了我的精神内耗.xlsx"
df = pd.read_excel("raw_data/" + name)

df.dropna(inplace=True, subset=["comment_content"])

comment_contents = df["comment_content"]
sentiment_score = []
isPositive = []
for comment_content in comment_contents:
	try:
		sentiment_result = sentiment(comment_content)
		try:
			sentiment_result = json.loads(sentiment_result)
		except Exception as e:
			print(e)
			sentiment_result = {"Positive": 0.5, "Sentiment": "Neutral"}
		sentiment_score.append(sentiment_result['Positive'])
		isPositive.append(sentiment_result['Sentiment'])
	except UnicodeEncodeError:
		sentiment_score.append(0.5)
df["sentiment_score"] = sentiment_score
df["sentiment"] = isPositive
df.to_excel("clear_data_" + name, index=False)
