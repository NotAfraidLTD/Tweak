LWeChat.plist    -                注入的宿主程序包名配置文件

Makefile             -               make文件

Tweak.xm          -               源码文件，xm格式文件支持c/oc/logo语法，x格式支持logo语法

control               -               控制文件，保存项目的配置信息

obj                     -               生成的framework文件夹  

package            -               编译生成的.deb包

TweakMakeHeader            工程头文件( Hook的宿主包的类interface , 都有顺序 )

余下的是新建文件 , 需要在Makefile引用 .
