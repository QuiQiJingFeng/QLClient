# -*- coding: utf-8 -*-
import os
from os.path import *
import time
import json
import re
import struct
import fnmatch
import zipfile
import hashlib
import errno
import types
import collections
from collections import OrderedDict
import codecs

class Util:
    'Util类 提供常用方法的封装'
    # 定义私有属性

    ######################################################################
    # 文件目录处理相关
    ######################################################################
    # 检测是否是目录 return boolean
    @staticmethod
    def isDir(path):
        return os.path.isdir(path)

    # 检测是否是文件  return boolean
    @staticmethod
    def isFile(path):
        return os.path.isfile(path)

    # 检测是否是绝对路径  return boolean
    @staticmethod
    def isAbsolute(path):
        return os.path.isabs(path)

    # 检测路径是否存在 return boolean
    @staticmethod
    def isExist(path):
        return os.path.exists(path)

    # 返回路径的最后一节  return string
    @staticmethod
    def getBaseName(path):
        return os.path.basename(path)

    # 返回path的目录 returnstring
    @staticmethod
    def getPathDir(path):
        return os.path.dirname(path)

    # 路径字符转换
    # 在Linux和Mac平台上，该函数会原样返回path
    # 在windows平台上会将路径中所有字符转换为小写，并将所有斜杠转换为反斜杠。
    # return string
    @staticmethod
    def getConvertPath(path):
        return os.path.normcase(path)

    # 返回文件的后缀名(例如: .lua) return string
    @staticmethod
    def getLastSuffixName(path):
        return os.path.splitext(path)[1]

    # 获取文件的大小
    @staticmethod
    def getFileSize(path):
        return os.path.getsize(path)

    # 获取文件或目录的最后修改时间
    @staticmethod
    def getLastChangeTime(path):
        return os.path.getmtime(path)

    @staticmethod
    def changeWorkDirectory(path):
        return os.chdir(path)

    @staticmethod
    def getCurWorkDirectory():
        return os.getcwd()

    @staticmethod
    def ensureDir(dirname):
        try:
            os.makedirs(dirname)
        except OSError, e:
            if e.errno != errno.EEXIST:
                raise

    ######################################################################
    # 字符串处理相关
    ######################################################################
    # 字符串替换 并返回替换后的字符串
    # @content 原始字符串
    # @filt   匹配字符串
    # @rep    匹配后进行替换的字符串
    # @times  替换的次数 本参数可以省略,如果省略就意味着全部替换
    @staticmethod
    def replaceStr(content, filt, rep, times):
        return content.replace(filt, rep, times)

    # 字符串查找
    # 找到返回索引，找不到返回-1
    # 从下标0开始，查找在字符串里第一个出现的子串
    @staticmethod
    def findStr(content, sub):
        return content.find(sub, 0)

    # 字符串反向查找
    # 找到返回索引，找不到返回-1
    # 从下标0开始，查找在字符串里第一个出现的子串
    @staticmethod
    def rfindStr(content, sub):
        return content.rfind(sub, 0)

    # 字符串分割
    # @content 待分割的字符串
    # @char 分隔符
    # @times  分割次数,如果不指定则有多少分割多少
    @staticmethod
    def splitStr(content, char, times):
        return content.split(char, times)

    # 字符串截取 左闭右开区间[)
    # [0:3] 截取从索引[0] ~ [2] 的字符(不包含[3])
    # [:]   截取全部的字符
    # [6:]  截取索引[6]到末尾的所有字符
    # [:-3] 截取从索引[0]到索引[-4]之间的所有字符
    # [3]   截取索引为[3]的字符
    # [-5:-3] 截取索引[-5] ~ [-4]之间的所有字符
    @staticmethod
    def subStr(content, start, end):
        return content[start:end]

    # 获取字符串的长度
    @staticmethod
    def getStrLength(content):
        return len(content)

    # 去掉字符串中的空格
    @staticmethod
    def trimStr(content):
        return content.replace(" ", "")

    ######################################################################
    # 日期相关
    ######################################################################
    # 将格林威治时间转换成可读的日期
    # %y 两位数的年份表示（00-99）
    # %Y 四位数的年份表示（000-9999）
    # %m 月份（01-12）
    # %d 月内中的一天（0-31）
    # %H 24小时制小时数（0-23）
    # %I 12小时制小时数（01-12）
    # %M 分钟数（00=59）
    # %S 秒（00-59）
    # %a 本地简化星期名称
    # %A 本地完整星期名称
    # %b 本地简化的月份名称
    # %B 本地完整的月份名称
    # %c 本地相应的日期表示和时间表示
    # %j 年内的一天（001-366）
    # %p 本地A.M.或P.M.的等价符
    # %U 一年中的星期数（00-53）星期天为星期的开始
    # %w 星期（0-6），星期天为星期的开始
    # %W 一年中的星期数（00-53）星期一为星期的开始
    # %x 本地相应的日期表示
    # %X 本地相应的时间表示
    # %Z 当前时区的名称
    # %% %号本身
    @staticmethod
    def convertToDate(seconds):
        return time.strftime("%Y-%m-%d %H:%M:%S", seconds)

    # 获取当前的格林威治时间
    @staticmethod
    def getTime():
        return time.time()

    ######################################################################
    # 列表相关
    ######################################################################
    # 列表排序
    # @list 待排序的列表
    # @reverse 是否反转排列顺序
    # @compre 比较函数
    @staticmethod
    def sortList(array, rever, compare):
        sorted(array, reverse=rever, cmp=compare)

    ######################################################################
    # 文件相关
    ######################################################################
    # 获取文本文件内容
    @staticmethod
    def getStringFromFile(path,mode='rb'):
        content = ""
        try:
            file = open(path, mode)
            content = file.read()
            file.close()
        except Exception, e:
            print '-------------------'
            print 'READ FILE ERROR:', e, path
            print '-------------------'
        return content

    # 写入文件内容
    @staticmethod
    def writeStringToFile(path, content):
        try:
            file = open(path, "wb")
            file.write(content)
            file.close()
        except Exception, e:
            print '-------------------'
            print 'WRITE FILE ERROR:', e, path
            print '-------------------'

    # 向文件中追加内容
    @staticmethod
    def appendStringToFile(path, content):
        try:
            file = open(path, "a+")
            file.write(content)
        except Exception, e:
            print '-------------------'
            print 'APPEND FILE ERROR:', e, path
            print '-------------------'

    @staticmethod
    def getHash(content):
        # line=f.readline()
        md5_hash = hashlib.md5()
        md5_hash.update(content)
        return md5_hash.hexdigest()

    ######################################################################
    # lua 文件加密
    ######################################################################
    # 加密lua文件
    # @rootDir 加密的根目录
    # @outDir 输出目录
    # @xxteKey 加密的key
    # @xxteaSign 文件头 用来确定文件从哪里开始
    # @includes 筛选器 ['*.lua']
    # @excludes 要跳过的目录
    # @rblist 对于二进制文件 以rb方式读取,文本文件以rU方式读取
    # XXTEA_KEY = "10cc4fdee2fcd047"  XXTEA_SIGN = "gclR3cu9"
    @staticmethod
    def processFile(isEncrypt=True, rootDir='src', outDir='.', xxteKey='10cc4fdee2fcd047', xxteaSign='gclR3cu9', includes=['*.lua'], excludes=[]):
        outDir = os.path.abspath(outDir)
        _DELTA = 0x9E3779B9
        def _long2str(v, w):
            n = (len(v) - 1) << 2
            if w:
                m = v[-1]
                if (m < n - 3) or (m > n):
                    return ''
                n = m
            s = struct.pack('<%iL' % len(v), *v)
            return s[0:n] if w else s

        def _str2long(s, w):
            n = len(s)
            m = (4 - (n & 3) & 3) + n
            s = s.ljust(m, "\0")
            v = list(struct.unpack('<%iL' % (m >> 2), s))
            if w:
                v.append(n)
            return v

        def Encrypt(str, key):
            if str == '':
                return str
            v = _str2long(str, True)
            k = _str2long(key.ljust(16, "\0"), False)
            n = len(v) - 1
            z = v[n]
            y = v[0]
            sum = 0
            q = 6 + 52 // (n + 1)
            while q > 0:
                sum = (sum + _DELTA) & 0xffffffff
                e = sum >> 2 & 3
                for p in xrange(n):
                    y = v[p + 1]
                    v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff
                    z = v[p]
                y = v[0]
                v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff
                z = v[n]
                q -= 1
            return _long2str(v, False)

        def Decrypt(str, key):
            if str == '':
                return str
            v = _str2long(str, False)
            k = _str2long(key.ljust(16, "\0"), False)
            n = len(v) - 1
            z = v[n]
            y = v[0]
            q = 6 + 52 // (n + 1)
            sum = (q * _DELTA) & 0xffffffff
            while (sum != 0):
                e = sum >> 2 & 3
                for p in xrange(n, 0, -1):
                    z = v[p - 1]
                    v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff
                    y = v[p]
                z = v[n]
                v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff
                y = v[0]
                sum = (sum - _DELTA) & 0xffffffff
            return _long2str(v, True)

        def DoEncrypt(rootDir, xxteKey, xxteaSign, includes, excludes):
            originDir = Util.getCurWorkDirectory()
            #切换到目标上一级目录
            Util.changeWorkDirectory(rootDir + "/../")
            baseName = Util.getBaseName(rootDir)
            for root, dirs, files in os.walk(baseName, topdown=True):
                dirs[:] = [d for d in dirs if d not in excludes]
                for pat in includes:
                    for f in fnmatch.filter(files, pat):
                        file = open(os.path.join(root, f), 'rb')
                        s = file.read()
                        if xxteaSign == s[:len(xxteaSign)]:
                            print u"文件已经被加密过了,无法被再次加密"
                            return
                        str = Encrypt(s, xxteKey)
                        str = xxteaSign + str    
                        file.close()
                        outpath = os.path.join(outDir,root)
                        if(not os.path.exists(outpath)):  
                            os.makedirs(os.path.join(outDir,root))
                        file = open(os.path.join(outDir,root, f), "wb")
                        file.write(str)
                        file.close()
            Util.changeWorkDirectory(originDir)

        def DeEncrypt(rootDir, xxteKey, xxteaSign, includes, excludes):
            originDir = Util.getCurWorkDirectory()
            #切换到目标上一级目录
            Util.changeWorkDirectory(rootDir + "/../")
            baseName = Util.getBaseName(rootDir)
            for root, dirs, files in os.walk(baseName, topdown=True):
                dirs[:] = [d for d in dirs if d not in excludes]
                for pat in includes:
                    for f in fnmatch.filter(files, pat):
                        file = open(os.path.join(root, f), "rb")
                        s = file.read()
                        if xxteaSign != s[:len(xxteaSign)]:
                            print u"文件没有被加密,无法解密"
                            return
                        s = s[len(xxteaSign):]
                        str = Decrypt(s, xxteKey)
                        file.close()
                        outpath = os.path.join(outDir,root)
                        if(not os.path.exists(outpath)):  
                            os.makedirs(os.path.join(outDir,root))
                        file = open(os.path.join(outDir,root, f), "wb")
                        file.write(str)
                        file.close()
            Util.changeWorkDirectory(originDir)
        if(isEncrypt):
            DoEncrypt(rootDir, xxteKey, xxteaSign, includes, excludes)
        else:
            DeEncrypt(rootDir, xxteKey, xxteaSign, includes, excludes)
    @staticmethod
    def encryptFolder(rootDir='src', outDir='.', xxteKey='10cc4fdee2fcd047', xxteaSign='gclR3cu9', includes=['*.lua'], excludes=[]):    
        Util.processFile(True,rootDir, outDir, xxteKey, xxteaSign, includes, excludes)
    @staticmethod
    def decryptFolder(rootDir='src', outDir='.', xxteKey='10cc4fdee2fcd047', xxteaSign='gclR3cu9', includes=['*.lua'], excludes=[]):
        Util.processFile(False,rootDir, outDir, xxteKey, xxteaSign, includes, excludes)

    ######################################################################    # 压缩指定目录
    ######################################################################
    # @rootDir 要压缩的目录
    # @fileName 压缩文件的名称 xxx.zip
    # @includes 筛选要压缩的文件
    # @excludes 不进入压缩包的目录
    # 正在生成的存档不仅包含压缩文件数据，还包含“额外的文件属性” (创建时间)
    # 如果这种元数据在压缩之间有所不同，那么您将永远不会得到相同的校验和，因为压缩文件的元数据已更改，并已包含在归档中。
    # @return md5 所以要通过计算原始文件 来生成MD5,避免两次生成的MD5只不一样
    
    @staticmethod
    def zipFolder(rootDir, fileName, includes=["*.*"],excludes=[]):
        originDir = Util.getCurWorkDirectory()
        #切换到目标上一级目录
        Util.changeWorkDirectory(rootDir + "/../")
        baseName = Util.getBaseName(rootDir)
        md5 = hashlib.md5()
        # 创建zip文件
        zf = zipfile.ZipFile(fileName, "w", zipfile.ZIP_DEFLATED)
        # 遍历文件夹
        for root, dirs, files in os.walk(baseName, topdown=True):
            dirs[:] = [d for d in dirs if d not in excludes]
            # 文件夹排序
            dirs.sort()
            # 文件排序
            files.sort()
            # 添加初始目录
            zf.write(root + "/")
            # 筛选指定文件 并添加到zip文件中
            for pat in includes:
                for f in fnmatch.filter(files, pat):
                    filePath = os.path.join(root, f)
                    s = Util.getStringFromFile(filePath,'rb')
                    zf.writestr(filePath, s)
                    md5.update(s)
        Util.changeWorkDirectory(originDir)
        return md5.hexdigest()


    @staticmethod
    def zipFolderEx(rootDir, includes=['*.*'],excludes=[]):
        originDir = Util.getCurWorkDirectory()
        #切换到目标上一级目录
        Util.changeWorkDirectory(rootDir + "/../")
        baseName = Util.getBaseName(rootDir)
        
        assets = {}
        # 遍历文件夹
        for root, dirs, files in os.walk(baseName, topdown=True):
            dirs[:] = [d for d in dirs if d not in excludes]
            # 文件夹排序
            dirs.sort()
            # 文件排序
            files.sort()
            md5 = hashlib.md5()
            # 创建zip文件
            zfileName = root.replace("/","_")
            zfileName = zfileName.replace("\\","_")
            zfileName = zfileName + ".zip"
            zf = zipfile.ZipFile(zfileName, "w", zipfile.ZIP_DEFLATED)
            # 添加初始目录
            zf.write(root + "/")
            # 筛选指定文件 并添加到zip文件中
            for pat in includes:
                for f in fnmatch.filter(files, pat):
                    filePath = os.path.join(root, f)
                    s = Util.getStringFromFile(filePath,'rb')
                    zf.writestr(filePath, s)
                    md5.update(s)
            assets[zfileName] = md5.hexdigest()
        Util.changeWorkDirectory(originDir)
        return assets

    ######################################################################
    #######################################################################
    # 
    @staticmethod
    def ConvertJsonObjectToLuaStr(jsonObj):
        def space_str(layer):
            lua_str = ""
            for i in range(0,layer):
                lua_str += '\t'
            return lua_str
         
        def dic_to_lua_str(data,layer=0):
            d_type = type(data)
            if  d_type is types.StringTypes or d_type is str or d_type is types.UnicodeType:
                return "'" + data + "'"
            elif d_type is types.BooleanType:
                if data:
                    return 'true'
                else:
                    return 'false'
            elif d_type is types.IntType or d_type is types.LongType or d_type is types.FloatType:
                return str(data)
            elif d_type is types.ListType:
                lua_str = "{\n"
                lua_str += space_str(layer+1)
                for i in range(0,len(data)):
                    lua_str += dic_to_lua_str(data[i],layer+1)
                    if i < len(data)-1:
                        lua_str += ','
                lua_str += '\n'
                lua_str += space_str(layer)
                lua_str +=  '}'
                return lua_str
            elif (d_type is types.DictType or d_type is collections.OrderedDict):
                lua_str = ''
                lua_str += "\n"
                lua_str += space_str(layer)
                lua_str += "{\n"
                data_len = len(data)
                data_count = 0
                for k,v in data.items():
                    data_count += 1
                    lua_str += space_str(layer+1)
                    if type(k) is types.IntType:
                        lua_str += '[' + str(k) + ']'
                    else:
                        lua_str += k 
                    lua_str += ' = '
                    try:
                        lua_str += dic_to_lua_str(v,layer +1)
                        if data_count < data_len:
                            lua_str += ',\n'
         
                    except Exception, e:
                        print 'error in ',k,v
                        raise
                lua_str += '\n'
                lua_str += space_str(layer)
                lua_str += '}'
                return lua_str
            else:
                print d_type , '==========is error'
                return None

        return dic_to_lua_str(jsonObj)
    
    #Util.splitFile("client-gongsheFinal.zip","client-gongsheFinal",1024 * 1024)
    @staticmethod
    def splitFile(srcpath,despath,chunksize = 1024):
            'split the files into chunks, and save them into despath'
            if not os.path.exists(despath):
                os.mkdir(despath)
            chunknum = 0
            inputfile = open(srcpath, 'rb') #rb 读二进制文件
            try:
                while 1:
                    chunk = inputfile.read(chunksize)
                    if not chunk: #文件块是空的
                        break
                    chunknum += 1
                    filename = os.path.join(despath, ("part--%04d" % chunknum))
                    fileobj = open(filename, 'wb')
                    fileobj.write(chunk)
            except IOError:
                print "read file error\n"
                raise IOError
            finally:
                inputfile.close()
            return chunknum

    #Util.mergeFile("client-gongsheFinal","./client-gongsheFinal.zip")
    @staticmethod
    def mergeFile(srcpath,despath):
		'将src路径下的所有文件块合并，并存储到des路径下。'
		if not os.path.exists(srcpath):
			print "srcpath doesn't exists, you need a srcpath"
			raise IOError
		files = os.listdir(srcpath)
		with open(despath, 'wb') as output:
			for eachfile in files:
				filepath = os.path.join(srcpath, eachfile)
				with open(filepath, 'rb') as infile:
					data = infile.read()
					output.write(data)

    #获取指定目录下所有文件的md5码并写入文件
    @staticmethod
    def getSpecialFolderMD5List(specialDir):
        baseName = Util.getBaseName(specialDir)
        Util.changeWorkDirectory(specialDir + "/../")
        assets = {}
        for root, dirs, files in os.walk(baseName, topdown=True):
            for f in files:
                sourcePath = os.path.join(root, f)
                file = open(sourcePath, 'rb')
                s = file.read()  
                file.close()
                md5 = Util.getHash(s)
                assets[sourcePath] = md5
        return assets