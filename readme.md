# 操作指南

1. 安装最新版powershell7（win系统自带的旧版，会出现语法错误）
   ```powershell
   winget search Microsoft.PowerShell
   winget install --id Microsoft.PowerShell --source winget
   ```

   

2. 打开脚本所在文件夹，右键管理员模式运行powershell7
   ![image-20250405192700149](C:\Users\wanderingxs\AppData\Roaming\Typora\typora-user-images\image-20250405192700149.png)

3. 启用系统休眠（只需要执行一次）
   ```powershell
   powercfg /hibernate on
   ```

4. 启用脚本执行权限

   1. 方法一：每次运行都要执行，安全性高
      ```powershell
      Set-ExecutionPolicy Bypass -Scope Process -Force
      ```

   2. 方法二：只需要执行一次，安全性较低
      ```powershell
      Set-ExecutionPolicy RemoteSigned -Force
      ```

5. 执行脚本
   ```powershell
   ./auto_sleep.ps1
   ```

   ```powershell
   ./auto_hibernate.ps1
   ```

   

6. 按照提示输入睡眠/休眠间隔，系统自动创建定时任务

7. 按任意键退出，脚本将自动删除之前创建的定时睡眠任务