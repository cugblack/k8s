`assassinate` -强制删除死节点，而不重新复制任何数据。如果不能删除节点，这是最后的手段

`bootstrap` -监视/管理节点的引导进程

`cleanup` -触发立即清除不再属于某个节点的键。默认情况下，清除所有键空间

`clearsnapshot` -从给定的键空间中删除具有给定名称的快照。如果没有指定快照名称，我们将删除所有快照

`compact` -对一个或多个表强制执行（高度）压缩，或者对给定的SSTables强制执行用户定义的压缩

`compactionhistory` -打印压缩历史

`compactionstats` -打印压缩统计

`decommission` -取消我连接的节点

`describecluster` -打印集群的名称，snitch，partitioner和模式版本

`describering` -显示给定键空间的令牌范围信息

`disableautocompaction` -禁用给定键空间和表的自动压缩

`disablebackup` -禁用增量备份

`disablebinary` -禁用本地传输（二进制协议）

`disablegossip` -禁用gossip（有效地标记节点）

`disablehandoff` -禁用存储提示的切换

`disablehintsfordc` -禁用数据中心的提示

`disablethrift` -禁用thrift服务器

`drain` -排空节点（停止接受写入并刷新所有表）

`enableautocompaction` -为给定的键空间和表启用自动压缩

`enablebackup` -启用增量备份

`enablebinary` -重用本地传输（二进制协议）

`enablegossip` -重新启用gossip

`enablehandoff` -重新启用存储在当前节点上的未来提示

`enablehintsfordc` -为先前禁用的数据中心启用提示

`enablethrift` -重新启用thrift服务器

`failuredetector` -显示集群的故障检测器信息

`flush` -刷新一个或多个表

`garbagecollect` -从一个或多个表中删除已删除的数据

`gcstats` - 打印GC统计信息

`getcompactionthreshold` -为给定表打印最小和最大压缩阈值

`getcompactionthroughput` -打印系统中压缩的MB / s吞吐量上限

`getconcurrentcompactors -获取系统中并发压缩程序的数量。

`getendpoints` -打印拥有键的端点

`getinterdcstreamthroughput` -打印系统中数据中心内数据流的Mb / s吞吐量上限

`getlogginglevels` -获取运行时日志记录级别

`getsstables` -打印拥有该键的sstable文件名

`getstreamthroughput` -打印系统中数据流传输的Mb / s吞吐量上限

`gettimeout` -以ms为单位打印给定类型的超时

`gettraceprobability` -打印当前跟踪概率值

`gossipinfo` -显示集群的闲话信息

`help` -显示帮助信息

`info` -打印节点信息（正常运行时间，负载，...）

`invalidatecountercache` -使计数器高速缓存无效

`invalidatekeycache` -使密钥缓存无效

`invalidaterowcache` -使行高速缓存无效

`join` -加入环

`listsnapshots` -列出所有快照在磁盘上的大小和真实大小。

`move` -将令牌环上的节点移动到新令牌

`netstats` -在提供的主机（默认情况下为连接节点）上打印网络信息

`pausehandoff` -暂停提示传递过程

`proxyhistograms` -打印网络操作的统计直方图

`rangekeysample` -显示跨所有键空间保持的采样键

`rebuild` -通过从其他节点流式传输重建数据（类似于引导）

`rebuild_index` -给定表的本地辅助索引的完全重建

`refresh` - 将新放置的SSTables加载到系统，而不重新启动

`refreshsizeestimates` -刷新system.size_estimates

`reloadtriggers` -重新加载触发器类

`relocatesstables` -将sstables重定位到正确的磁盘

`removenode` -显示当前节点删除的状态，强制完成挂起节点的删除或删除提供的ID


`repair` -修复一个或多个表

`replaybatchlog` -启动批处理重放并等待完成

`resetlocalschema` -重置节点的本地模式和重新同步

`resumehandoff` -恢复提示传递过程

`ring` -打印令牌环的信息

`scrub` -擦除（重建sstables）一个或多个表

`setcachecapacity` -设置全局键，行和计数器缓存容量（以MB为单位）

`setcachekeystosave` -设置由每个缓存快速重启后的热身保存键。0禁用

`setcompactionthreshold` -为给定表设置最小和最大压缩阈值

`setcompactionthroughput` -设置系统中compaction MB / s的吞吐量，或者0禁用限制

`setconcurrentcompactors` -设置系统中的并发压缩程序数

`sethintedhandoffthrottlekb` -设置提示的切换速度（传输线程的速度kb/s）。

`setinterdcstreamthroughput` -设置系统中数据中心内数据流的Mb / s吞吐量上限，或0以禁用调节

`setlogginglevel` -设置给定类的日志级别阈值。如果类和级别都为空/ null，它将重置为初始配置

`setstreamthroughput` -设置系统中数据流的Mb / s吞吐量上限，或0禁用调节

`settimeout` -设置指定的超时（以毫秒为单位），或0以禁用超时

`settraceprobability` -设置将任何给定请求跟踪为值的概率。0禁用，1启用所有请求，0是默认值

`snapshot` -获取指定键空间或指定表快照的快照

`status` -打印集群信息（状态，负载，ID，...）

`statusbackup` -增量备份的状态

`statusbinary` -本地传输的状态（二进制协议）

`statusgossip` - gossip的状态

`statushandoff` -在当前节点上存储未来提示的状态

`statusthrift` - thrift节点服务器的状态

`stop` -停止压缩

`stopdaemon` -停止cassandra守护进程

`tablehistograms` -打印给定表的统计直方图

`tablestats` -打印表上的统计信息

`toppartitions` -为给定列簇采样和打印最活动的分区

`tpstats` -打印线程池的使用统计信息

`truncatehints` -截断本地节点上的所有提示，或截断指定的端点的提示。

`upgradesstables` -重写不在当前版本上的sstables（用于请求的表）（从而将它们升级到所述当前版本）

`verify` -验证（检查数据校验）一个或多个表

`version` -打印cassandra版本

`viewbuildstatus` -显示实例化视图构建的进度