# -*- coding: utf-8 -*-
# author:           inspurer(月小水长)
# create_time:      2021/7/6 22:19
# 运行环境           Python3.6+
# github            https://github.com/inspurer
# 微信公众号         月小水长

# -*- coding: utf-8 -*-
# pc_type           lenovo
# create_time:      2020/2/19 12:16
# file_name:        super_comment.py
# github            https://github.com/inspurer
# qq邮箱            2391527690@qq.com
# 微信公众号         月小水长(ID: inspurer)


import execjs
jspython = '''str62keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
/**
* 10进制值转换为62进制
* @param {String} int10 10进制值
* @return {String} 62进制值
*/
function int10to62(int10) {
    var s62 = '';
    var r = 0;
    while (int10 != 0) {
            r = int10 % 62;
            s62 = this.str62keys.charAt(r) + s62;
            int10 = Math.floor(int10 / 62);
    }
    return s62;
}
/**
* 62进制值转换为10进制
* @param {String} str62 62进制值
* @return {String} 10进制值
*/
function str62to10(str62) {
    var i10 = 0;
    for (var i = 0; i < str62.length; i++) {
            var n = str62.length - i - 1;
            var s = str62.substr(i, 1);  // str62[i]; 字符串用数组方式获取，IE下不支持为“undefined”
            i10 += parseInt(str62keys.indexOf(s)) * Math.pow(62, n);
    }
    return i10;
}
/**
* id转换为mid
* @param {String} id 微博id，如 "201110410216293360"
* @return {String} 微博mid，如 "wr4mOFqpbO"
*/
function id2mid(id) {
    if (typeof (id) != 'string') {
            return false; // id数值较大，必须为字符串！
    }
    var mid = '';
    for (var i = id.length - 7; i > -7; i = i - 7) //从最后往前以7字节为一组读取mid
    {
            var offset1 = i < 0 ? 0 : i;
            var offset2 = i + 7;
            var num = id.substring(offset1, offset2);
            num = int10to62(num);
            mid = num + mid;
    }
    return mid;
}
/**
* mid转换为id
* @param {String} mid 微博mid，如 "wr4mOFqpbO"
* @return {String} 微博id，如 "201110410216293360"
*/
function mid2id(mid) {
    var id = '';
    for (var i = mid.length - 4; i > -4; i = i - 4) //从最后往前以4字节为一组读取mid字符
    {
            var offset1 = i < 0 ? 0 : i;
            var len = i < 0 ? parseInt(mid.length % 4) : 4;
            var str = mid.substr(offset1, len);
            str = str62to10(str).toString();
            if (offset1 > 0) //若不是第一组，则不足7位补0
            {
                    while (str.length < 7) {
                            str = '0' + str;
                    }
            }
            id = str + id;
    }
    return id;
}'''
ctx = execjs.compile(jspython) # 编译 js

def mid2id(mid):
    return ctx.call('mid2id', mid)

def id2mid(id):
    return ctx.call('id2mid', id)
