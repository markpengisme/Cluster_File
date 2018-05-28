# Cluster_File
**專題名稱:基於K8s的Quorum快速部屬工具**


## 第一階段一鍵部署7個節點私有鏈
>從quorum-examples的7nodes架在vm裡移植到k8s上面。

### 使用方式
`./one_click_deployment.sh `

### 相關檔案
- `one_click_deployment.sh`：一鍵部署7節點腳本檔案
- `7nodes`：7個節點的固定資料
- `script`：腳本集合

## 第二階段一鍵部署任意數節點私有鏈並控制
>從7個節點改成任意節點並控制它。

### 功能
1. Quick deployment N's node
2. Quick add N's node
3. Delete node
4. Change UI
5. Block generator

### 使用方式
`./one_click_control_node.sh`

### 相關檔案
- `one_click_deployment.sh`：：一鍵控制節點腳本檔案
- `node_default`：節點裡的固定資料
- `controlscript`：腳本集合
- `node`：節點的dockerfile