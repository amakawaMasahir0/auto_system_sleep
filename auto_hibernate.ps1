# 要求管理员权限
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$($MyInvocation.MyCommand.Path)`"" -Verb RunAs
    exit
}

# 输入验证
do {
    $minutes = Read-Host "`n请输入自动休眠间隔时间（分钟）"
    if (-not ($minutes -match '^\d+$') -or [int]$minutes -le 0) {
        Write-Host "输入无效，请输入大于0的整数！"
    } else {
        $t = [int]$minutes
        break
    }
} while ($true)

# 创建计划任务
$taskName = "AutoHibernateTask_$(Get-Date -Format yyyyMMddHHmmss)"
$intervalMinutes = $t
$action = New-ScheduledTaskAction -Execute "shutdown.exe" -Argument "/h /f"
$trigger = New-ScheduledTaskTrigger -AtStartup

Register-ScheduledTask -TaskName $taskName -Action $action -Trigger $trigger -Description "自动休眠任务" -User "SYSTEM" -RunLevel Highest
# 获取已创建的任务
$task = Get-ScheduledTask -TaskName $taskName

# 设置重复间隔和持续时间,持续时间先给2天
$task.Triggers[0].Repetition.Interval = [System.Xml.XmlConvert]::ToString([System.TimeSpan]::FromMinutes($intervalMinutes))
$task.Triggers[0].Repetition.Duration = [System.Xml.XmlConvert]::ToString([System.TimeSpan]::FromDays(2))

# 更新任务
$task | Set-ScheduledTask
# 创建计划任务
$taskName = "AutoHibernateTask_$(Get-Date -Format yyyyMMddHHmmss)"

# xml法不好用，可用的xml可以参考上述创建方式生成的xml
# # iso 8601 Time format
# $iso8601String = $(Get-Date).AddHours(8).ToString("yyyy-MM-ddTHH:mm:sszzz")
# $xmlContent = @"
# <?xml version="1.0" encoding="Unicode"?>
# <Task version="1.4" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">
#   <RegistrationInfo>
#     <Description>自动休眠任务</Description>
#   </RegistrationInfo>
#   <Triggers>
#     <CalendarTrigger>
#       <Repetition>
#         <Interval>PT$(($t*60))S</Interval>
#         <StopAtDurationEnd>false</StopAtDurationEnd>
#       </Repetition>
#       <StartBoundary>2025-04-06T05:09:33+08:00</StartBoundary>
#       <ExecutionTimeLimit>PT5M</ExecutionTimeLimit>
#       <Enabled>true</Enabled>
#     </CalendarTrigger>
#   </Triggers>
#   <Principals>
#     <Principal id="Author">
#       <RunLevel>HighestAvailable</RunLevel>
#     </Principal>
#   </Principals>
#   <Actions Context="Author">
#     <Exec>
#       <Command>shutdown.exe</Command>
#       <Arguments>/h /f</Arguments>
#     </Exec>
#   </Actions>
# </Task>
# "@

# $xmlPath = "$env:TEMP\hibernate_task.xml"
# $xmlContent | Out-File -FilePath $xmlPath -Encoding Unicode
# schtasks /Create /XML $xmlPath /TN $taskName /F | Out-Null
# Remove-Item $xmlPath

Write-Host "`n已创建自动休眠任务：$taskName"
Write-Host "`n按任意键删除计划任务并退出..."

# 等待任意按键
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

# 删除计划任务
try {
    schtasks /Delete /TN $taskName /F | Out-Null
    Write-Host "`n已成功删除计划任务！"
}
catch {
    Write-Host "`n删除任务时发生错误：$_"
}

Write-Host "按任意键退出..."
$null = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")