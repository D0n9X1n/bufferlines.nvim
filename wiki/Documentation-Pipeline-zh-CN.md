# 文档流水线

[English](Documentation-Pipeline)

本 wiki 是该分支**唯一的文档撰写来源**。`doc/` 下没有任何手写内容。

## 目录结构

| 路径 | 作用 |
| --- | --- |
| `wiki/*.md` | 英文指南（发布为 wiki 页面） |
| `wiki/*-zh-CN.md` | 中文指南（发布为 wiki 页面） |
| `wiki/_Sidebar.md` | 双语 wiki 侧边栏 |
| `wiki/help/*.txt` | Vim 帮助片段——参考手册的撰写源 |
| `doc/bufferlines.txt` | **生成**的产物，已提交到 Git |
| `scripts/gen_help.py` | 生成器（仅依赖标准库） |
| `scripts/test_docs.py` | 文档测试（仅依赖标准库） |
| `scripts/check_wiki.py` | wiki 结构检查（仅依赖标准库） |
| `scripts/publish-wiki.sh` | wiki 镜像发布脚本（由 `scripts/test_wiki_sync.py` 测试） |

`doc/bufferlines.txt` 保持提交状态，因此未获取 wiki 的用户安装插件后仍可使用
`:help bufferlines.nvim`。

## 生成

```sh
python3 scripts/gen_help.py          # 重写 doc/bufferlines.txt
python3 scripts/gen_help.py --check  # 若不同步则失败
```

生成器按文件名顺序拼接 `wiki/help/*.txt`，之间以单个换行连接。它是确定性的：相同的源文件
始终产生逐字节相同的输出，不含时间戳或依赖具体机器的值。章节顺序由文件名的数字前缀决定，
因此调整顺序意味着重命名文件。

## 编辑参考手册

编辑 `wiki/help/` 中的片段，然后重新生成：

```sh
$EDITOR wiki/help/05-multiline-buffer-tabs.txt
python3 scripts/gen_help.py
python3 scripts/test_docs.py
```

切勿直接编辑 `doc/bufferlines.txt`——下一次生成会覆盖它，在此之前 `--check` 也会失败。

编辑时请保持帮助标签（`*bufferlines-...*`）完整；`wiki/help/01-contents.txt` 中的目录会列出
这些标签，测试会检查其中引用的每个标签都确实存在。

## 测试

`scripts/test_docs.py` 会检查：

- **生成漂移**——`doc/bufferlines.txt` 与源文件逐字节一致。
- **确定性**——连续生成两次输出完全相同。
- **标签完整性**——目录中列出的每个帮助标签都有定义，且分支专有标签得到保留。
- **双语一致性**——每个英文 wiki 页面都有对应的 `-zh-CN` 页面，且两者包含相同的图片 URL 集合。
- **链接一致性**——README 与其中文版指向相同的 wiki 页面，且每个 wiki 内部链接都能解析到实际
  存在的页面。
- **契约准确性**——文档不会重新引入「header 定义了 `q` 映射」这一已废弃的说法。

使用 `python3 scripts/test_docs.py` 运行。它只需要 Python 标准库。

## 发布

`.github/workflows/publish-wiki.yml` 会在每次推送到 `main` 时以及手动触发时，将 `wiki/`
发布到 GitHub wiki。只读的校验任务会先运行 `scripts/check_wiki.py`（每个页面都有 `-zh-CN`
对应页面、第 3 行互相链接、内部链接可解析，且 `_Sidebar.md` 与两个首页都列出所有页面）以及离线
发布测试，随后发布任务运行 `scripts/publish-wiki.sh`。

wiki 是 `wiki/*.md` 的**镜像**：GitHub wiki 中存在但 `wiki/` 中不存在的页面会在下次发布时被
删除，在 Git 中重命名的页面在 wiki 中也会随之重命名。请在本仓库中撰写所有页面——在 wiki 网页
界面中的修改会被覆盖或删除。每次发布都是 wiki `master` 上的一个普通提交；不会强制推送，源文件
未变化时不会产生提交。

工作流成功运行的前提条件：

1. **wiki 必须已存在并完成初始化。** 在通过网页界面保存第一个页面之前，GitHub 不会创建
   `<repo>.wiki.git` 仓库。请打开仓库的 **Wiki** 标签页并创建任意一个页面。在此之前，克隆
   步骤会失败。
2. **使用内置 `GITHUB_TOKEN`，仅为发布任务授予 `contents: write` 权限。**
   发布到本仓库的 wiki 不需要额外 secret 或个人令牌。校验任务仍使用只读权限。
   认证或发布失败会使工作流失败，不再静默跳过发布。

令牌只通过 `GIT_ASKPASS` 传给 git，并会先被遮蔽；它不会出现在 URL 或 git 参数中。源页面、
源目录或 wiki 页面是符号链接时会拒绝发布。
英文 Vim 参考手册与双语指南分别维护；`--check` 检查生成帮助的字节一致性，不能验证翻译的语义一致性。
