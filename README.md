# Lumio

基于 Qt 6 的应用程序，集成了 LibRaw 库用于处理数码相机的 RAW 文件。

Raw Processor：[PixRaw](https://github.com/nenhall/PixRaw)

## 功能特性

- 读取和解析 RAW 图像文件（支持 Canon CR2/CR3、Nikon NEF、Sony ARW 等格式）
- 提取 RAW 文件的元数据（相机型号、ISO、快门速度、光圈、焦距等）
- 解码 RAW 图像数据
- 提取嵌入的缩略图

## 依赖项

- Qt 6.8+
- LibRaw

## 构建指南

### 1. 安装 vcpkg（如果尚未安装）

```powershell
# 克隆 vcpkg
git clone https://github.com/Microsoft/vcpkg.git
cd vcpkg

# 运行引导脚本
.\bootstrap-vcpkg.bat

# 将 vcpkg 添加到环境变量（可选）
```

### 2. 安装 LibRaw

```powershell
# 使用 vcpkg 安装 LibRaw
.\vcpkg install libraw:x64-windows
```

### 3. 配置和编译项目

```powershell
# 进入项目目录
cd d:\Code\questech\Lumio

# 配置 CMake（指定 vcpkg toolchain 文件）
cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=[vcpkg路径]/scripts/buildsystems/vcpkg.cmake

# 例如：
# cmake -B build -S . -DCMAKE_TOOLCHAIN_FILE=C:/vcpkg/scripts/buildsystems/vcpkg.cmake

# 编译项目
cmake --build build --config Release
```

### 4. 运行程序

```powershell
# 运行程序（不带参数）
.\build\Release\appLumio.exe

# 运行程序并处理 RAW 文件
.\build\Release\appLumio.exe path\to\your\image.CR2
```

## 使用示例

### C++ 代码示例

```cpp
#include "RawImageProcessor.h"
#include <QDebug>

// 创建处理器实例
RawImageProcessor processor;

// 打开 RAW 文件
if (processor.openFile("image.CR2")) {
    // 获取元数据
    QMap<QString, QString> metadata = processor.getMetadata();
    for (auto it = metadata.constBegin(); it != metadata.constEnd(); ++it) {
        qDebug() << it.key() << ":" << it.value();
    }
    
    // 获取缩略图
    QImage thumbnail = processor.getThumbnail();
    if (!thumbnail.isNull()) {
        thumbnail.save("thumbnail.jpg");
    }
    
    // 解码完整图像
    QImage fullImage = processor.decodeImage();
    if (!fullImage.isNull()) {
        fullImage.save("decoded.jpg");
    }
    
    processor.close();
} else {
    qDebug() << "错误:" << processor.getLastError();
}
```

## 支持的 RAW 格式

LibRaw 支持超过 500 种相机型号的 RAW 格式，包括但不限于：

- **Canon**: .CR2, .CR3, .CRW
- **Nikon**: .NEF, .NRW
- **Sony**: .ARW, .SRF, .SR2
- **Fujifilm**: .RAF
- **Olympus**: .ORF
- **Panasonic**: .RW2
- **Pentax**: .PEF, .DNG
- **Adobe**: .DNG

完整的支持列表请参考 [LibRaw 官方文档](https://www.libraw.org/supported-cameras)。

## 项目结构

```
Lumio/
├── CMakeLists.txt          # CMake 构建配置
├── main.cpp                # 主程序入口（包含 LibRaw 示例）
├── Main.qml                # QML 界面
├── RawImageProcessor.h     # RAW 图像处理器头文件
├── RawImageProcessor.cpp   # RAW 图像处理器实现
└── README.md               # 本文件
```

## 许可证

- Lumio 项目: [您的许可证]
- LibRaw: LGPL v2.1 或 CDDL v1.0

## 参考资料

- [LibRaw 官方网站](https://www.libraw.org/)
- [LibRaw GitHub 仓库](https://github.com/LibRaw/LibRaw)
- [Qt 官方文档](https://doc.qt.io/)

