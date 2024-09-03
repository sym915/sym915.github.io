*************************************************************************
*                                                                       
*              《能源是福还是祸？——能源丰裕国经济增长分流的政治逻辑》            
*                              第四节代码                         
*                                                                       
*                                                                       
*                         北京外国语大学国际关系学院                     
*                                 宋亦明                                 
*                                                                       
*                                                                    
* 说明                                                                      
* 使用者如发现代码的任何错误，欢迎通过本邮箱向作者反馈: sym915@bfsu.edu.cn        
*                                                                       
*************************************************************************



***1.打开Excel数据并另存为STATA数据
*文件路径、文件名称和sheet名称均为笔者电脑所示。读者可根据自身需要选择新的文件路径、名称和sheet名称
import excel "/Users/sym915/Desktop/Panel Data.xlsx", sheet("Panel Data") firstrow clear
*将文件保存为STATA的dta格式文件
save Panel_Data.dta, replace

***2.检查数据结构；描述性统计；汇报变量的统计特征值
**2.1.查看数据集的大致信息
describe
* summarize后可以跟具体变量的名称，如果不跟变量名称，则默认对全部变量进行描述性分析
summarize
* ssc install outreg2 如果没有安装outreg2，则使用本命令安装
outreg2 using 描述性统计：统计特征值.doc, replace sum(log) title(Decriptive statistics)
* 可以使用tabstat命令对特定的变量和统计量进行描述性统计。详见网页：https://zhuanlan.zhihu.com/p/268525387
**2.2.汇报相关系数
*其一，皮尔逊相关系数
pwcorr Aspm1 Aicf1 Aprs1 Anal3 Crty1 Cwar1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg1 Ceth1 Cnds1 Crus2, sig star (0.05)
*其二，斯皮尔曼相关系数
spearman Aspm1 Aicf1 Aprs1 Anal3 Crty1 Cwar1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg1 Ceth1 Cnds1 Crus2, pw star(0.05)
**2.3.检视核心变量是否呈现出正态分布。
histogram Aegr1 , normal  //画直方图
histogram Aspm6 , normal
*其余不再例举
kdensity Aegr1 , normal normop(lpattern(dash))  //画核密度图
kdensity Aspm6 , normal normop(lpattern(dash))
*其余不再例举

***3.设置面板数据
* 确定panel variable和time variable
xtset Iccd Iyea

***4.绘制描述性统计图
graph box Aegr1, over(Aspm1) ytitle(经济增长速度)  //Aspm1与Aegr1的关系，图1
graph box Aicf1, over(Aspm1)  //Aspm1与Aicf1的关系，图2
graph box Aprs1, over(Aspm1)  //Aspm1与Aprs1的关系，图3
*绘制部分图表时需要使用由模糊集数据转换二来的截面数据
import excel "/Users/sym915/Desktop/Fussy Sets Data.xlsx", sheet("Sheet1") firstrow clear
twoway (lfitci Anal3 Aicf1)(scatter Anal3 Aicf1, mlabel(Iabb) mlabcolor(maroon)), ytitle(能源产业畸大程度) xtitle(能源产业联盟实力)  //Aicf1与Anal3的关系，图4
twoway (lfitci Anal3 Aprs1)(scatter Anal3 Aprs1, mlabel(Iabb) mlabcolor(maroon)), ytitle(能源产业畸大程度) xtitle(能源领域实行的产权制度)  //Aprs1与Anal3的关系，图5
generate lnAegr1=log(Aegr1)
twoway (lfitci lnAegr1 Anal3)(scatter lnAegr1 Anal3, mlabel(Iabb) mlabcolor(maroon)), ytitle(经济增长速度) xtitle(能源产业畸大程度)  //Anal3与lnAegr1的关系，图6
twoway (lfitci lnAegr1 Bcor1)(scatter lnAegr1 Bcor1, mlabel(Iabb) mlabcolor(maroon)), ytitle(经济增长速度) xtitle(石油储量)  //Bcor1与lnAegr1的关系，图7
twoway (lfitci lnAegr1 Bngr1)(scatter lnAegr1 Bngr1, mlabel(Iabb) mlabcolor(maroon)), ytitle(经济增长速度) xtitle(天然气储量)  //Bngr1与lnAegr1的关系，图8
*根据清晰集的A-spm-1数据手动录入进入截面数据当中，用新生成的截面数据重置图1、图2和图3.
graph box lnAegr1, over(Aspm1) ytitle(经济增长速度)  //Aspm1与Aegr1的关系，图1-New，最终采用此图。图1-New与图1可以加以对照。手动录入因Aegr1负数而无法转化为自然对数而产生的缺失值
graph box Aicf1, over(Aspm1)  //Aspm1与Aicf1的关系，图2-New，最终采用此图。图2-New与图2可以加以对照
graph box Aprs1, over(Aspm1)  //Aspm1与Aprs1的关系，图3-New，最终采用此图。图3-New与图3可以加以对照
*至此重新打开面板数据
use "/Users/sym915/Desktop/Panel Data.dta"  //路径设定因人而异。

***5.处理缺失值
* 本研究采取线性拟合插值
* 给所有空缺值空出来位置
tsfill, full
* 利用"ipolate"命令填充（只能填充一部分，如果缺失值位于头/尾，则无法填充）
* 只能一个一个地处理每一个variable （e.g. Aegs1)，无法一次性处理全部变量（因为每一组变量的拟合不同）
* bys Iccd的作用是仅填充缺失值，如果不加上这一段，则会改变原有数据的值（即跑出来是根据线性拟合模拟出的新的一组数据）
bys Iccd: ipolate Aegr1 Iyea, generate(ipAegr1)
* 如果实在需要首尾数据，可在命令最后加上epolate，（外推值，相对于内插值），如：
bys Iccd : ipolate Aegr3 Iyea, generate(ipAegr3 ) epolate
* 对于是否用外推法填充首尾值的建议是先看一下数据的图，是否存在明显线性趋势或者走向，如果存在拐点（即非线性），则不太适合
* 参考：https://www.lianxh.cn/news/4404052e7b336.html和https://bbs.pinggu.org/thread-7241146-1-1.html
* 说明：ipolate属于回归法，即建立线性模型补充空值。官方说明：https://www.stata.com/manuals/dipolate.pdf。多重插补法（mi）目前为止还没有适用于面板数据的code。开发者回复如下： “Neither -ice- nor -mi impute- has an imputation method specifically designed for panel data.  (The -mi xtset- command does declare panel data but does not change which imputation methods are available.)  We do, however, have a FAQ that has a few suggestions for applying -mi impute- to panel data.  The link is http://www.stata.com/support/faqs/statistics/clustering-and-mi-impute/”
* 画图只能针对一个变量下的多一个或国家画图，看看拟合结果是否合理
twoway (line Aegs1 Iyea if Iccd==20 , sort)
twoway (line ipAegs1 Iyea if Iccd==20, sort)
* 多个国家的命令直接在括号后加入即可，比如：
twoway (line Aegs1 Iyea if Iccd==20 , sort) (line Aegs1 Iyea if Iccd==52 , sort) 
* 目前的插补方法只能基于现有数据模拟缺失数据，如果这个国家自1950年至2020年没有数据记录的话，是无法插补这一空缺的
*将C-ppl-1和C-nds-1转化为自然对数
generate lnCppl1=log(Cppl1)
drop Cppl1
rename lnCppl1 Cppl1
generate lnCnds1=log(Cnds1)
drop Cnds1
rename lnCnds1 Cnds1
*重新给变量排序
order Inum Icou Iabb Iccd Iyea Aegr1 Aegr2 Aegr3 Aegr4 Aegr5 Aegr6 Aspm1 Aspm2 Aspm3 Aspm4 Aspm5 Aspm6 Aspm7 Aicf1 Aprs1 Aprs2 Aprs3 Aprs4 Aprs5 Anal1 Anal2 Anal3 Bcop1 Bcop2 Bngp1 Bngp2 Bcor1 Bngr1 Bopd1 Bopd2 Bgpd1 Bgpd2 Bcoe1 Bcoe2 Bnge1 Bnge2 Crty1 Crty2 Cwar1 Cncp1 Cncp2 Cncp3 Citq1 Citq2 Citq3 Cgvp1 Cgvp2 Cgvp3 Cgvp4 Cppl1 Cppl2 Crlg1 Crlg2 Ceth1 Cnds1 Crus1 Crus2 Crgd1 Crgd2 Crgd3 Crgd4

***6.使用OLS模型
**6.1使用面板数据
quietly reg Aicf1 Aspm1  //成立，符号方向正确（+）且显著
reg Aicf1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4 //成立，符号方向正确（+）且显著
quietly reg Aprs1 Aspm1  //成立，符号方向正确（+）且显著
reg Aprs1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4 //成立，符号方向正确（+）且显著
quietly reg Anal3 Aicf1  //成立，符号方向正确（+）且显著
reg Anal3 L.Aicf1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4 //成立，符号方向正确（+）且显著
quietly reg Anal3 Aprs1  //成立，符号方向正确（+）且显著
reg Anal3 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4 //成立，符号方向正确（+）且显著
quietly reg Aegr1 Anal3  //成立，符号方向正确(-)且显著
reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2  //成立，符号方向正确(-)且显著。仅纳入B组变量
quietly reg Aegr1 Aspm1  //成立，符号方向正确(-)且显著
reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4  //成立，符号方向正确(-)且显著。由于L.Cncp1与L.Aspm1的皮尔逊相关系数超过了0.7，两者存在共线性。并且由于L.Cncp1、L.Citq2、L.Cgvp1高度相关，三者之间两两的皮尔逊相关系数均高于0.8，因此剔除3个变量以降低共线性问题。
**6.2检视异方差问题
quietly reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4  //重复上述回归，但不显示结果
rvfplot  //画残差图
estat hettest, iid   //使用拟合值BP检验
estat hettest, iid rhs  //使用所有变量进行BP检验
estat imtest, white  //进行怀特检验
*残差图、BP检验和怀特检验表明存在异方差问题
*6.3检视自相关问题
quietly reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4  //重复上述回归，但不显示结果
predict e1,r  //计算残差并计为e1
twoway (lfit e1 L.e1)(scatter e1 L.e1) //画残差图。残差图拟合线具有明显的斜率，至少表明存在1阶自相关。用同样的方法画残差图，可以发现更高阶也存在自相关问题
estat bgodfrey  //样本不应包括多个面板，无法提供BG检验结果
wntestq e1  //样本不应包括多个面板，无法提供Q检验结果
estat dwatson  //样本不应包括多个面板，无法提供DW检验结果
*6.4检视多重共线性问题
quietly reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2  //排除地区哑变量后重复上述回归，但不显示结果
estat vif  //计算各变量的方差膨胀因子VIF。VIF均值为5.6，小于10。故而不用担心多重共线性问题
*6.5经过各种检验后，重复6.1的步骤。只不过将OLS改变为OLS+稳健标准误，以便解决异方差和自相关问题
quietly reg Aicf1 Aspm1, robust //成立，符号方向正确（+）且显著
reg Aicf1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //成立，符号方向正确（+）且显著
estimates store 模型（1）_因变量：Aicf1
quietly reg Aprs1 Aspm1, robust  //成立，符号方向正确（+）且显著
reg Aprs1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //成立，符号方向正确（+）且显著
estimates store 模型（2）_因变量：Aprs1
quietly reg Anal3 Aicf1, robust //成立，符号方向正确（+）且显著
reg Anal3 L.Aicf1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //成立，符号方向正确（+）且显著
estimates store 模型（3）_因变量：Anal3
quietly reg Anal3 Aprs1, robust  //成立，符号方向正确（+）且显著
reg Anal3 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //成立，符号方向正确（+）且显著
estimates store 模型（4）_因变量：Anal3
quietly reg Aegr1 Anal3, robust  //成立，符号方向正确(-)且显著
reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2, robust  //成立，符号方向正确(-)且显著。仅纳入B组变量
estimates store 模型（5）_因变量：Aegr1
quietly reg Aegr1 Aspm1, robust  //成立，符号方向正确(-)且显著
reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust  //成立，符号方向正确(-)且显著。由于L.Cncp1与L.Aspm1的皮尔逊相关系数超过了0.7，两者存在共线性。并且由于L.Cncp1、L.Citq2、L.Cgvp1高度相关，三者之间两两的皮尔逊相关系数均高于0.8，因此剔除3个变量以降低共线性问题
estimates store 模型（6）_因变量：Aegr1
*用coefplot呈现回归结果
ssc install coefplot
coefplot 模型（1）_因变量：Aicf1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（2）_因变量：Aprs1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（3）_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（4）_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（5）_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（6）_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
*coefplot 模型（1）_因变量：Aicf1 || 模型（2）_因变量：Aprs1 || 模型（3）_因变量：Anal3 || 模型（4）_因变量：Anal3 || 模型（5）_因变量：Aegr1 || 模型（6）_因变量：Aegr1 ,drop(_cons) xline(0)  //不同模型的置信区间差别比较大，在此仅分别汇报6个图而非1个合成的图
*用estout倒出数据
ssc install estout
esttab 模型（1）_因变量：Aicf1 模型（2）_因变量：Aprs1 模型（3）_因变量：Anal3 模型（4）_因变量：Anal3 模型（5）_因变量：Aegr1 模型（6）_因变量：Aegr1 using /Users/sym915/Desktop/OLSR_1.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
drop _est_模型（1）_因变量：Aicf1 _est_模型（2）_因变量：Aprs1 _est_模型（3）_因变量：Anal3 _est_模型（4）_因变量：Anal3 _est_模型（5）_因变量：Aegr1 _est_模型（6）_因变量：Aegr1
*6.6使用截面数据，结果可用于稳健性检验。同样采取OLS+稳健标准误
*打开截面数据
quietly reg Aicf1 Aspm1, robust  //成立，符号方向正确（+）且显著
quietly reg Aicf1 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //不成立，符号方向正确（+）但不显著
reg Aicf1 Aspm1 Bopd2 Bgpd2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust   //成立，符号方向正确（+）且显著，剔除Bcoe2 Bnge2后结果显著
estimates store 模型（7）_因变量：Aicf1
quietly reg Aprs1 Aspm1, robust  //成立，符号方向正确（+）且显著
reg Aprs1 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //成立，符号方向正确（+）且显著
estimates store 模型（8）_因变量：Aprs1
quietly reg Anal3 Aicf1, robust  //成立，符号方向正确（+）且显著
reg Anal3 Aicf1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //成立，符号方向正确（+）且显著。保留Cncp1、Citq2 、Cgvp1三者中的任何一个都显著。由于Cncp1、Citq2、Cgvp1高度相关,为避免共线性保留任意其一即可
estimates store 模型（9）_因变量：Anal3
quietly reg Anal3 Aprs1, robust  //成立，符号方向正确（+）且显著
reg Anal3 Aprs1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust //成立，符号方向正确（+）且显著
estimates store 模型（10）_因变量：Anal3
quietly reg lnAegr1 Anal3, robust  //成立，符号方向正确（-）且显著
reg lnAegr1 Anal3 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //成立，符号方向正确（-）且显著
estimates store 模型（11）_因变量：Aegr1
quietly reg Aegr1 Aspm1, robust  //成立，符号方向正确(-)且显著
reg Aegr1 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //成立，符号方向正确(-)且显著.由于Cncp1与Aspm1的皮尔逊相关系数超过了0.7，两者存在共线性。并且由于Cncp1、Citq2、Cgvp1高度相关，三者之间两两的皮尔逊相关系数均高于0.8，因此剔除3个变量以降低共线性问题。
estimates store 模型（12）_因变量：Aegr1
estat vif  //计算各变量的方差膨胀因子VIF。VIF均值为4.4，小于10。故而不用担心多重共线性问题
esttab 模型（7）_因变量：Aicf1 模型（8）_因变量：Aprs1 模型（9）_因变量：Anal3 模型（10）_因变量：Anal3 模型（11）_因变量：Aegr1 模型（12）_因变量：Aegr1 using /Users/sym915/Desktop/OLSR_2.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
drop _est_模型（7）_因变量：Aicf1 _est_模型（8）_因变量：Aprs1 _est_模型（9）_因变量：Anal3 _est_模型（10）_因变量：Anal3 _est_模型（11）_因变量：Aegr1 _est_模型（12）_因变量：Aegr1

***7.使用Logit模型（直接使用稳健标准误）
**7.1使用面板数据
gen Aicf2 =(Aicf1>=3 & Aicf!=.) //生成Aicf1的哑变量，手动调整错误转录的数据
generate Anal4=(Anal3>=3 & Anal3!=.) //生成Anal3的哑变量，手动调整错误转录的数据
quietly logit Aicf2 Aspm1, robust //成立，符号方向正确（+）且显著
logit Aicf2 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust  //成立，符号方向正确（+）且显著
estimates store 模型（1）_因变量：Aicf2
quietly logit Aprs2 Aspm1, robust  //成立，符号方向正确（+）且显著
quietly logit Aprs2 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust  //无结果，反馈如下：note: L.Aspm1 != 0 predicts success perfectly L.Aspm1 dropped and 168 obs not used outcome = Bngr1 > 1.313274 predicts data perfectly r(2000);
logit Aprs2 L.Aspm1 L.Bngp1 L.Cwar1 L.Citq2 L.Cgvp1 L.Cppl2 L.Ceth1 L.Cnds1 L.Crus2, robust //逐一删除导致上述问题的变量后成立，符号方向正确（+）且显著
estimates store 模型（2）_因变量：Aprs2
quietly logit Anal4 Aicf2, robust //成立，符号方向正确（+）且显著
logit Anal4 L.Aicf2 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1  L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust //删除存有共线性的后L.Citq2 L.Cgvp1成立，符号方向正确（+）且显著
estimates store 模型（3）_因变量：Anal4
quietly logit Anal4 Aprs2, robust  //成立，符号方向正确（+）且显著
logit Anal4 L.Aprs2 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2, robust //成立，符号方向正确（+）且显著。仅纳入B组变量
estimates store 模型（4）_因变量：Anal4
quietly logit Aegr2 Anal4, robust  //成立，符号方向正确（+）且显著
logit Aegr2 L.Anal4 L.Bcor1 L.Bngr1, robust //成立，符号方向正确（+）且显著。这表明在控制能源丰裕度的情况下，能源产业越畸大，经济增长速度越低
estimates store 模型（5）_因变量：Aegr2
quietly logit Aegr2 Aspm1, robust  //成立，符号方向正确（+）且显著
logit Aegr2 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2, robust //成立，符号方向正确（+）且显著
estimates store 模型（6）_因变量：Aegr2
esttab 模型（1）_因变量：Aicf2 模型（2）_因变量：Aprs2 模型（3）_因变量：Anal4 模型（4）_因变量：Anal4 模型（5）_因变量：Aegr2 模型（6）_因变量：Aegr2 using /Users/sym915/Desktop/logit_1.rtf, replace b(%6.3f) se(%6.3f) nogap compress se pr2 mtitle star (* 0.1 ** 0.05 *** 0.01)
*可在上述所有命令后加上 “or” 以便查看几率比
drop _est_模型（1）_因变量：Aicf2 _est_模型（2）_因变量：Aprs2 _est_模型（3）_因变量：Anal4 _est_模型（4）_因变量：Anal4 _est_模型（5）_因变量：Aegr2 _est_模型（6）_因变量：Aegr2
**7.2使用截面数据
gen Aicf2 =(Aicf1>=3)
generate Anal4=(Anal3>=3) 
*另外还根据清晰集需要手动录入Aprs2的数据
quietly logit Aicf2 Aspm1, robust  //成立，符号方向正确（+）且显著
logit Aicf2 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //无结果，反馈如下： convergence not achieved，即未能实现收敛
quietly logit Aprs2 Aspm1, robust  //成立，符号方向正确（+）且显著
logit Aprs2 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //变量太多，无结果
quietly logit Anal4 Aicf2, robust  //成立，符号方向正确（+）且显著
logit Anal4 Aicf2 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //变量太多，无结果
quietly logit Anal4 Aprs2, robust  //成立，符号方向正确（+）且显著
logit Anal4 Aprs2 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //变量太多，无结果
quietly logit Aegr2 Anal4, robust  //成立，符号方向正确（+）且显著
logit Aegr2 Anal4 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cncp1 Citq2 Cgvp1 Cppl2 Crlg2 Ceth1 Cnds1 Crus2, robust  //变量太多，无结果
quietly logit Aegr2 Aspm1, robust  //成立，符号方向正确（+）且显著
logit Aegr2 Aspm1 Bopd2 Bgpd2 Bcoe2 Bnge2 Crty1 Cppl2 Crlg2 Ceth1 Cnds1, robust //成立，符号方向正确（+）且显著。需要删掉4个所在地区哑变量，否则导致Stata删除样本（从39减为22个）并且不汇报标准误、P值等关键参数
*可在上述所有命令后加上 “or” 以便查看几率比
estimates store 模型（7）_因变量：Aegr2
esttab 模型（7）_因变量：Aegr2 using /Users/sym915/Desktop/logit_2.rtf, replace b(%6.3f) se(%6.3f) nogap compress se pr2 mtitle star (* 0.1 ** 0.05 *** 0.01)
drop _est_模型（7）_因变量：Aegr2

***8.使用面板模型
*如果重新打开数据，则需要重新设置面板
xtset Iccd Iyea
*查看面板数据的统计特征
xtdes  //查看面板结构是否为平衡面板
xtsum  //显示组内、组间和整体的统计指标
xtline Aegr1 //显示特定变量的时间序列图，用",overlay"可以将其叠在一起，其他变量略
**8.1混合回归：聚类稳健标准误
quietly reg Aicf1 Aspm1, vce(cluster Iccd)  //成立，符号方向正确（+）且显著 
reg Aicf1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, vce(cluster Iccd)  //成立，符号方向正确（+）且显著
estimates store 模型（1）_混合回归_因变量：Aicf1
quietly reg Aprs1 Aspm1,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
reg Aprs1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
estimates store 模型（2）_混合回归_因变量：Aprs1
quietly reg Anal3 Aicf1,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
reg Anal3 L.Aicf1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
estimates store 模型（3）_混合回归_因变量：Anal3
quietly reg Anal3 Aprs1,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
reg Anal3 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
estimates store 模型（4）_混合回归_因变量：Anal3
quietly reg Aegr1 Anal3,   vce(cluster Iccd)   //符号方向正确（-），在10%水平上不成立，在15%水平上成立
reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2, vce(cluster Iccd)  //符号方向正确（-），在10%水平上不成立，在15%水平上成立。仅纳入B组变量
estimates store 模型（5）_混合回归_因变量：Aegr1
quietly reg Aegr1 Aspm1,  vce(cluster Iccd)  //成立，符号方向正确（-）且显著
reg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4,  vce(cluster Iccd)  //成立，符号方向正确（-）且显著由于Cncp1与Aspm1的皮尔逊相关系数超过了0.7，两者存在共线性。并且由于Cncp1、Citq2、Cgvp1高度相关，三者之间两两的皮尔逊相关系数均高于0.8，因此剔除3个变量以降低共线性问题
estimates store 模型（6）_混合回归_因变量：Aegr1
*特别说明：由于经济现代化始点的测量Aspm1不随时间变化而变化，因此会因共线性问题而被省略。故而，当以Aspm1为经济现代化始点的测量时，无法进行固定效应分析
**8.2随机效应（稳健标准误）
quietly xtreg Aicf1 Aspm1, re robust  //成立，符号方向正确（+）且显著
xtreg Aicf1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（+）且显著
estimates store 模型（7）_随机效应_因变量：Aicf1
quietly xtreg Aprs1 Aspm1, re robust  //成立，符号方向正确（+）且显著
xtreg Aprs1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（+）且显著
estimates store 模型（8）_随机效应_因变量：Aprs1
quietly xtreg Anal3 Aicf1, re robust  //成立，符号方向正确（+）且显著
xtreg Anal3 L.Aicf1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（+）且显著
estimates store 模型（9）_随机效应_因变量：Anal3
quietly xtreg Anal3 Aprs1, re robust  //不成立，符号方向正确（+）但不显著
quietly xtreg Anal3 Aprs1, re   //放弃稳健标准误后成立，符号方向正确（+）且显著
xtreg Anal3 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（+）且显著
estimates store 模型（10）_随机效应_因变量：Anal3
quietly xtreg Aegr1 Anal3, re robust  //不成立，符号方向正确（-）但不显著
estimates store 模型（11）_随机效应_因变量：Aegr1
quietly xtreg Aegr1 Aspm1, re robust  //成立，符号方向正确（-）且显著
xtreg Aegr1 L.Aspm1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（-）且显著
estimates store 模型（12）_随机效应_因变量：Aegr1
esttab 模型（1）_混合回归_因变量：Aicf1 模型（2）_混合回归_因变量：Aprs1 模型（3）_混合回归_因变量：Anal3 模型（4）_混合回归_因变量：Anal3 模型（5）_混合回归_因变量：Aegr1 模型（6）_混合回归_因变量：Aegr1 模型（7）_随机效应_因变量：Aicf1 模型（8）_随机效应_因变量：Aprs1 模型（9）_随机效应_因变量：Anal3 模型（10）_随机效应_因变量：Anal3 模型（11）_随机效应_因变量：Aegr1 模型（12）_随机效应_因变量：Aegr1 using /Users/sym915/Desktop/panel_1.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
coefplot 模型（1）_混合回归_因变量：Aicf1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（2）_混合回归_因变量：Aprs1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（3）_混合回归_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（4）_混合回归_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（5）_混合回归_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（6）_混合回归_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
*选择混合回归还是随机效应模型：LM检测
xttest0  //在上一行代码运行之后，紧跟本行代码
*结果显示 Prob > chibar2 =   1.0000 
*这一结果远大于0.05，则强烈接受“不存在个体随机效应”的原假设。在随机效应和混合回归之间，应该选择混合回归并汇报其结果
**8.3更换经济现代化始点测量后的混合回归：检验经济现代化始点与经济增长速度之间的关系
quietly reg Aegr1 Aspm6,  vce(cluster Iccd)  //成立，符号方向正确（+）且显著
reg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4,  vce(cluster Iccd)   //成立，符号方向正确（+）且显著
estimates store 模型（13）_混合回归_因变量：Aegr1
**8.4更换经济现代化始点测量后的固定效应：检验经济现代化始点与经济增长速度之间的关系（稳健标准误）
quietly xtreg Aegr1 Aspm6, fe robust  //成立，符号方向正确（+）且显著
xtreg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, fe robust  //在10%水平不成立。在20%水平成立，符号方向正确（+）且显著
estimates store 模型（14）_固定效应_因变量：Aegr1
xtreg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, fe //成立，符号方向正确（+）且显著
*根据要求，需要去掉r完成上述回归，并观察F检验的p值。结果显示Prob > F = 0.0000，所以强烈拒绝原假设，可以认为固定效应优于混合回归
estimates store 模型（15）_固定效应_因变量：Aegr1
**8.5更换经济现代化始点测量后的随机效应：检验经济现代化始点与经济增长速度之间的关系（稳健标准误）
quietly xtreg Aegr1 Aspm6, re robust  //成立，符号方向正确（+）且显著
xtreg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re robust  //成立，符号方向正确（+）且显著
estimates store 模型（16）_随机效应_因变量：Aegr1
xttest0  //结果显示 Prob > chibar2 =   1.0000。 这一结果远大于0.05，则强烈接受“不存在个体随机效应”的原假设。在随机效应和混合回归之间，应该选择混合回归并汇报其结果
esttab 模型（13）_混合回归_因变量：Aegr1 模型（14）_固定效应_因变量：Aegr1 模型（15）_固定效应_因变量：Aegr1 模型（16）_随机效应_因变量：Aegr1 using /Users/sym915/Desktop/panel_2.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star ( * 0.1 ** 0.05 *** 0.01)
coefplot 模型（13）_混合回归_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（14）_固定效应_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90 80)
coefplot 模型（15）_固定效应_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（16）_随机效应_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
**8.6更换经济现代化始点测量后的豪斯曼检验
*豪斯曼检验假设球型扰动项，所以在进行固定效应和随机效应估计时均不使用异方差或聚类稳健的标准误
xtreg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, fe
estimates store FE_Aspm6
xtreg Aegr1 L.Aspm6 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 L.Crgd1 L.Crgd2 L.Crgd3 L.Crgd4, re
estimates store RE_Aspm6
hausman FE_Aspm6 RE_Aspm6, constant sigmamore  //结果显示Prob>chi2 =0.0000，故而强烈拒绝原假设，应该使用固定效应模型而非随机效应模型
drop _est_模型（7）_随机效应_因变量：Aicf1 _est_模型（8）_随机效应_因变量：Aprs1 _est_模型（9）_随机效应_因变量：Anal3 _est_模型（10）_随机效应_因变量：Anal3 _est_模型（11）_随机效应_因变量：Aegr1 _est_模型（12）_随机效应_因变量：Aegr1 _est_模型（1）_混合回归_因变量：Aicf1 _est_模型（2）_混合回归_因变量：Aprs1 _est_模型（3）_混合回归_因变量：Anal3 _est_模型（4）_混合回归_因变量：Anal3 _est_模型（5）_混合回归_因变量：Aegr1 _est_模型（6）_混合回归_因变量：Aegr1 _est_模型（13）_混合回归_因变量：Aegr1 _est_模型（14）_固定效应_因变量：Aegr1 _est_模型（15）_固定效应_因变量：Aegr1 _est_模型（16）_随机效应_因变量：Aegr1

***9.使用2SLS回归（稳健标准误）
* 加入first命令以显示第一阶段结果 
**9.1 Aicf1内生变量，Aspm1工具变量
ivregress 2sls Anal3 (L.Aicf1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust first  //第一阶段成立，L.Aspm1与L.Aicf1符号方向正确（+）且显著。第二阶段成立，L.Aicf1与Anal3符号方向正确（+）且显著
estimates store 模型（1）_因变量：Anal3
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
quietly ivregress 2sls Anal3 (L.Aicf1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4 
estat firststage //结果：F值 = 9.46978。F统计量接近10但未超过，可能存在弱工具变量问题。对此可以使用对弱工具变量更不敏感的有限信息最大似然法（LIML），如下
ivregress liml Anal3 (L.Aicf1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust first  //第一阶段成立，L.Aspm1与L.Aicf1符号方向正确（+）且显著。第二阶段成立，L.Aicf1与Anal3符号方向正确（+）且显著
estimates store 模型（2）_因变量：Anal3
*LIMI的系数估计余2SLS非常接近。从侧面印证了弱工具变量问题并不严重
*豪斯曼检验，检视Aicf1是否存在内生性
quietly reg Anal3 L.Aicf1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4
estimates store ols
quietly ivregress 2sls Anal3 (L.Aicf1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4
estimates store iv
hausman iv ols, constant sigmamore  //结果：Prob>chi2 = 0.0034，拒绝“所有解释变量均为外生”的原假设，可以认为Aicf1为内生变量，应该使用IV而非OLS
estat endogenous  //异方差稳健的DWH检验，结果如下
*Durbin (score) chi2(1)          =  9.58964  (p = 0.0020)
*Wu-Hausman F(1,192)             =  8.92015  (p = 0.0032)
*上述2个p值均小于0.05，可以认为Aicf1为内生变量
**9.2 Aprs1内生变量，Aspm1工具变量
ivregress 2sls Anal3 (L.Aprs1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust first  //第一阶段成立，L.Aspm1与L.Aicf1符号方向正确（+）且显著。第二阶段成立，L.Aicf1与Anal3符号方向正确（+）且显著
estimates store 模型（3）_因变量：Anal3
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
quietly ivregress 2sls Anal3 (L.Aprs1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4
estat firststage  //结果：F值 = 13.7571。可以认定不存在弱工具变量问题
*豪斯曼检验，检视Aprs1是否存在内生性
quietly reg Anal3 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4
estimates store ols
quietly ivregress 2sls Anal3 (L.Aprs1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4
estimates store iv
hausman iv ols, constant sigmamore  //结果： Prob>chi2 =0.0163，拒绝“所有解释变量均为外生”的原假设，可以认为Aprs1为内生变量，应该使用IV而非OLS
estat endogenous
*Durbin (score) chi2(1)          =  6.45235  (p = 0.0111)
*Wu-Hausman F(1,192)             =  5.91203  (p = 0.0160)
*上述2个p值均小于0.05，可以认为Aprs1为内生变量
**9.3 Anal3内生变量，Aicf1和Aprs1工具变量
*9.3.1Aicf1和Aprs1同时作为工具变量
ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1 L.Aprs1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aicf1和L.Aprs1分别与L.Anal3符号方向正确（+）且显著。第二阶段成立，L.Anal3与Aegr1符号方向正确（-）且显著
estimates store 模型（4）_因变量：Aegr1
estat overid  //过度识别检验。结果显示工具变量可能与扰动项相关
quietly ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1 L.Aprs1)
estat firststage  //结果：F值 = 316.826。可以认定不存在弱工具变量问题
*豪斯曼检验，检视Anal3是否存在内生性
quietly reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store ols
quietly ivregress 2sls Aegr1 (L.Anal3= L.Aicf1 L.Aprs1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store iv
hausman iv ols, constant sigmamore  //结果： Prob>chi2 =0.3724，接受“所有解释变量均为外生”的原假设，可以认为Anal3为外生变量，应该使用OLS而非IV
estat endogenous
*Durbin (score) chi2(1)          =   .81196  (p = 0.3675)
*Wu-Hausman F(1,487)             =  .795322  (p = 0.3729)
*上述2个p值均大于0.1，可以认为Anal3为外生变量
*9.3.2Aicf1单独作为工具变量
ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aicf1与L.Anal3符号方向正确（+）且显著。第二阶段不成立，L.Anal3与Aegr1符号方向正确（-）且但不显著
estimates store 模型（5）_因变量：Aegr1
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
quietly ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1)
estat firststage  //结果：F值 = 482.134。可以认定不存在弱工具变量问题
*豪斯曼检验，检视Anal3是否存在内生性
quietly reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store ols
quietly ivregress 2sls Aegr1 (L.Anal3= L.Aicf1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store iv
hausman iv ols, constant sigmamore  //结果： Prob>chi2 =0.0548，在10%的水平上拒绝“所有解释变量均为外生”的原假设，可以认为Anal3为内生变量，应该使用IV而非OLS
estat endogenous
*Durbin (score) chi2(1)          =  3.76287  (p = 0.0524)
*Wu-Hausman F(1,487)             =  3.70777  (p = 0.0547)
*上述2个p值均小于0.1，在10%的水平上可以认为Anal3为内生变量
*9.3.3Aprs1单独作为工具变量
ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aprs1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aprs1分别与L.Anal3符号方向正确（+）且显著。第二阶段成立，L.Anal3与Aegr1符号方向正确（-）且显著
estimates store 模型（6）_因变量：Aegr1
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
quietly ivregress 2sls Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aprs1) 
estat firststage  //结果：F值 = 67.0484。可以认定不存在弱工具变量问题
*豪斯曼检验，检视Anal3是否存在内生性
quietly reg Aegr1 L.Anal3 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store ols
quietly ivregress 2sls Aegr1 (L.Anal3=L.Aprs1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2
estimates store iv
hausman iv ols, constant sigmamore  //结果： rob>chi2 =0.0000，拒绝“所有解释变量均为外生”的原假设，可以认为Anal3为内生变量，应该使用IV而非OLS
estat endogenous
*Durbin (score) chi2(1)          =  30.7576  (p = 0.0000)
*Wu-Hausman F(1,487)             =  32.0582  (p = 0.0000)
*上述2个p值均小于0.05，可以认为Anal3为内生变量
esttab 模型（1）_因变量：Anal3 模型（2）_因变量：Anal3 模型（3）_因变量：Anal3 模型（4）_因变量：Aegr1 模型（5）_因变量：Aegr1 模型（6）_因变量：Aegr1 using /Users/sym915/Desktop/2sls.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
coefplot 模型（1）_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（2）_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（3）_因变量：Anal3 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（4）_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（5）_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
coefplot 模型（6）_因变量：Aegr1 ,drop(_cons) xline(0) level (99 95 90)
drop _est_ols _est_iv _est_模型（1）_因变量：Anal3 _est_模型（2）_因变量：Anal3 _est_模型（3）_因变量：Anal3 _est_模型（4）_因变量：Aegr1 _est_模型（5）_因变量：Aegr1 _est_模型（6）_因变量：Aegr1

***10.稳健性检验
*方法一，使用OLS的截面数据，同6.6。略
*方法二，使用logit回归，同7.1和7.2。略
*方法三，使用GMM，以应对可能出现的异方差情形
**10.1 Aicf1内生变量，Aspm1工具变量
ivregress gmm Anal3 (L.Aicf1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust first  //第一阶段成立，L.Aspm1与L.Aicf1符号方向正确（+）且显著。第二阶段成立，L.Aicf1与Anal3符号方向正确（+）且显著
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
estimates store 模型（1）_因变量：Anal3
**10.2 Aprs1内生变量，Aspm1工具变量
ivregress gmm Anal3 (L.Aprs1=L.Aspm1) L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust first  //第一阶段成立，L.Aspm1与L.Aicf1符号方向正确（+）且显著。第二阶段成立，L.Aicf1与Anal3符号方向正确（+）且显著
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
estimates store 模型（2）_因变量：Anal3
*10.3 Anal3内生变量，Aicf1和Aprs1工具变量
*10.3.1Aicf1和Aprs1同时作为工具变量
ivregress gmm Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1 L.Aprs1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aicf1和L.Aprs1分别与L.Anal3符号方向正确（+）且显著。第二阶段不成立，L.Anal3与Aegr1符号方向正确（-）但不显著
estimates store 模型（3）_因变量：Aegr1
estat overid  //过度识别检验。结果显示工具变量可能与扰动项相关
**10.3.2Aicf1单独作为工具变量
ivregress gmm Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aicf1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aicf1与L.Anal3符号方向正确（+）且显著。第二阶段不成立，L.Anal3与Aegr1符号方向正确（-）且但不显著
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
estimates store 模型（4）_因变量：Aegr1
*10.3.3Aprs1单独作为工具变量
ivregress gmm Aegr1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 (L.Anal3= L.Aprs1), robust first  //仅包括B组控制变量。第一阶段成立，L.Aprs1与L.Anal3符号方向正确（+）且显著。第二阶段成立，L.Anal3与Aegr1符号方向正确（-）且显著
*工具变量个数等于内生变量个数，恰好识别而非过度识别。无需进行过度识别检验
estimates store 模型（5）_因变量：Aegr1
esttab 模型（1）_因变量：Anal3 模型（2）_因变量：Anal3 模型（3）_因变量：Aegr1 模型（4）_因变量：Aegr1 模型（5）_因变量：Aegr1 using /Users/sym915/Desktop/GMM.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
drop _est_模型（1）_因变量：Anal3 _est_模型（2）_因变量：Anal3 _est_模型（3）_因变量：Aegr1 _est_模型（4）_因变量：Aegr1 _est_模型（5）_因变量：Aegr1
*方法四，加入中心化之后的交互项，检验Aicf1和Aprs1对Anal3的影响
ssc install center  //中心化的非官方命令安装
center Aicf1 Aprs1
gen interact= c_Aicf1*c_Aprs1
reg Anal3 L.Aicf1 L.Aprs1 L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust  //加入交互项之前，L.Aicf1和L.Aprs1的符号方向正确（+）且显著
estimates store 模型（1）_因变量：Anal3
reg Anal3 L.Aicf1 L.Aprs1 interact L.Bcop1 L.Bngp1 L.Bcor1 L.Bngr1 L.Bopd2 L.Bgpd2 L.Bcoe2 L.Bnge2 L.Crty1 L.Cwar1 L.Cncp1 L.Citq2 L.Cgvp1 L.Cppl2 L.Crlg1 L.Ceth1 L.Cnds1 L.Crus2 Crgd1 Crgd2 Crgd3 Crgd4, robust  //加入交互项之后，L.Aicf1、L.Aprs1和interact的符号方向正确（+）且显著
estimates store 模型（2）_因变量：Anal3
esttab 模型（1）_因变量：Anal3 模型（2）_因变量：Anal3 using /Users/sym915/Desktop/interact.rtf, replace b(%6.3f) se(%6.3f) nogap compress se ar2 mtitle star (* 0.1 ** 0.05 *** 0.01)
drop c_Aicf1 c_Aprs1 interact _est_模型（1）_因变量：Anal3 _est_模型（2）_因变量：Anal3

***11.内生性检验
*方法一，使用时滞1年的自变量和控制变量数据，如上
*方法二，使用IV，如上
