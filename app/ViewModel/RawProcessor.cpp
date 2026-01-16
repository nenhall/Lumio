#include "RawProcessor.h"
#include <QBuffer>
#include <QDebug>
#include <QFileInfo>
#include <QtConcurrent>
#include <QThread>

RawProcessor::RawProcessor(QObject *parent)
    : QObject(parent)
{
    // 连接 QFutureWatcher 的 finished 信号
    connect(&m_decodeWatcher, &QFutureWatcher<QImage>::finished,
            this, &RawProcessor::onDecodeFinished);
}

RawProcessor::~RawProcessor()
{
    close();
}

bool RawProcessor::openFile(const QString& filePath)
{
    close();

    // 移除 file:/// 前缀
    QString localPath = filePath;
    if (localPath.startsWith("file:///")) {
        localPath = localPath.mid(8);
    } else if (localPath.startsWith("file://")) {
        localPath = localPath.mid(7);
    }

    QFileInfo fileInfo(localPath);
    if (!fileInfo.exists()) {
        m_lastError = QString("File not found: %1").arg(localPath);
        return false;
    }

#ifdef _WIN32
    bool success = m_processor.open(localPath.toStdWString());
#else
    bool success = m_processor.open(localPath.toStdString());
#endif

    if (success) {
        m_fileOpen = true;
        m_currentFile = localPath;
        m_lastError.clear();
        emit fileChanged();
    } else {
        m_lastError = QString::fromStdString(m_processor.getLastError());
    }

    return success;
}

QVariantMap RawProcessor::getMetadata() const
{
    QVariantMap metadata;

    if (!m_processor.isOpen()) {
        return metadata;
    }

    auto rawMetadata = m_processor.getMetadata();

    metadata["camera_make"] = QString::fromStdString(rawMetadata.camera_make);
    metadata["camera_model"] = QString::fromStdString(rawMetadata.camera_model);
    metadata["software"] = QString::fromStdString(rawMetadata.software);
    metadata["image_width"] = rawMetadata.image_width;
    metadata["image_height"] = rawMetadata.image_height;
    metadata["raw_width"] = rawMetadata.raw_width;
    metadata["raw_height"] = rawMetadata.raw_height;
    metadata["iso"] = rawMetadata.iso;
    metadata["shutter_speed"] = rawMetadata.shutter_speed;
    metadata["aperture"] = rawMetadata.aperture;
    metadata["focal_length"] = rawMetadata.focal_length;
    metadata["timestamp"] = static_cast<qlonglong>(rawMetadata.timestamp);
    metadata["wb_red"] = rawMetadata.wb_red;
    metadata["wb_green"] = rawMetadata.wb_green;
    metadata["wb_blue"] = rawMetadata.wb_blue;
    metadata["lens_model"] = QString::fromStdString(rawMetadata.lens_model);
    metadata["orientation"] = rawMetadata.orientation;
    metadata["is_raw"] = rawMetadata.is_raw;

    return metadata;
}

QImage RawProcessor::decodeImage()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        return QImage();
    }

    auto rawImage = m_processor.decodePreview();

    if (!rawImage.isValid()) {
        m_lastError = QString::fromStdString(m_processor.getLastError());
        return QImage();
    }

    // 转换 RawImage 为 QImage
    int width = rawImage.width();
    int height = rawImage.height();
    const uint8_t* data = rawImage.data();

    // 创建 QImage，直接引用 RawImage 的数据
    QImage qImage(data, width, height, rawImage.stride(), QImage::Format_RGB888);

    // 深拷贝一份，因为 RawImage 的数据会被销毁
    return qImage.copy();
}

QImage RawProcessor::decodeQuickPreview()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        return QImage();
    }

    auto rawImage = m_processor.decodeQuickPreview();

    if (!rawImage.isValid()) {
        m_lastError = QString::fromStdString(m_processor.getLastError());
        return QImage();
    }

    const uint8_t* data = rawImage.data();
    QImage qImage(data, rawImage.width(), rawImage.height(),
                  rawImage.stride(), QImage::Format_RGB888);
    return qImage.copy();
}

QImage RawProcessor::decodeMediumPreview()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        return QImage();
    }

    auto rawImage = m_processor.decodeMediumPreview();

    if (!rawImage.isValid()) {
        m_lastError = QString::fromStdString(m_processor.getLastError());
        return QImage();
    }

    const uint8_t* data = rawImage.data();
    QImage qImage(data, rawImage.width(), rawImage.height(),
                  rawImage.stride(), QImage::Format_RGB888);
    return qImage.copy();
}

QString RawProcessor::getPreviewBase64()
{
    QImage preview = decodeImage();
    if (preview.isNull()) {
        return "";
    }

    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    preview.save(&buffer, "JPEG");  // 使用 JPEG 压缩

    QString base64 = QString::fromLatin1(byteArray.toBase64());
    return QString("data:image/jpeg;base64,") + base64;
}

QImage RawProcessor::getThumbnail()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        return QImage();
    }

    // 优先使用 JPEG 缩略图（快速）
    auto jpegData = m_processor.getThumbnailData();
    if (jpegData.isValid()) {
        QByteArray jpegByteArray(reinterpret_cast<const char*>(jpegData.data()),
                               static_cast<int>(jpegData.size()));
        QImage result;
        if (result.loadFromData(jpegByteArray, "JPEG")) {
            m_lastError.clear();
            return result;
        }
    }

    // 如果 JPEG 缩略图失败或不存在，使用小尺寸预览
    m_lastError = "Using preview instead of thumbnail";
    auto rawImage = m_processor.decodePreview(640, 480);

    if (!rawImage.isValid()) {
        m_lastError = QString::fromStdString(m_processor.getLastError());
        return QImage();
    }

    // 转换 RawImage 为 QImage
    const uint8_t* data = rawImage.data();
    QImage qImage(data, rawImage.width(), rawImage.height(),
                  rawImage.stride(), QImage::Format_RGB888);

    return qImage.copy();
}

QString RawProcessor::getThumbnailBase64()
{
    QImage thumb = getThumbnail();
    if (thumb.isNull()) {
        return "";
    }

    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    thumb.save(&buffer, "JPEG");

    QString base64 = QString::fromLatin1(byteArray.toBase64());
    return QString("data:image/jpeg;base64,") + base64;
}

QString RawProcessor::getLastError() const
{
    return m_lastError;
}

bool RawProcessor::isFileOpen() const
{
    return m_processor.isOpen();
}

bool RawProcessor::isDecoding() const
{
    return m_decoding;
}

void RawProcessor::setDecoding(bool decoding)
{
    if (m_decoding != decoding) {
        m_decoding = decoding;
        emit decodingChanged();
    }
}

void RawProcessor::close()
{
    // 取消正在进行的解码
    cancelDecode();

    if (m_fileOpen) {
        m_processor.close();
        m_fileOpen = false;
        m_currentFile.clear();
        emit fileChanged();
    }
}

void RawProcessor::decodeAsync(int max_width, int max_height)
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        emit decodeFailed(m_lastError);
        return;
    }

    // 如果正在解码，先取消
    if (isDecoding()) {
        cancelDecode();
    }

    setDecoding(true);
    m_cancelRequested = 0;

    // 在后台线程解码
    QFuture<QImage> future = QtConcurrent::run([this, max_width, max_height]() {
        auto rawImage = m_processor.decodePreview(max_width, max_height);

        // 检查是否被取消
        if (m_cancelRequested.loadRelaxed()) {
            return QImage();
        }

        if (!rawImage.isValid()) {
            return QImage();  // 返回空图像表示失败
        }

        // 转换 RawImage 为 QImage
        const uint8_t* data = rawImage.data();
        QImage qImage(data, rawImage.width(), rawImage.height(),
                      rawImage.stride(), QImage::Format_RGB888);

        return qImage.copy();
    });

    m_decodeWatcher.setFuture(future);
}

void RawProcessor::decodeProgressive()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        emit decodeFailed(m_lastError);
        return;
    }

    // 如果正在解码，先取消
    if (isDecoding()) {
        cancelDecode();
    }

    setDecoding(true);
    m_cancelRequested = 0;

    // 在后台线程进行渐进式解码
    QFuture<QImage> future = QtConcurrent::run([this]() {
        const int totalStages = 3;

        // 阶段 1: 快速预览 (320x240)
        if (m_cancelRequested.loadRelaxed()) {
            return QImage();
        }

        auto rawImage1 = m_processor.decodePreview(320, 240);
        if (!rawImage1.isValid() || m_cancelRequested.loadRelaxed()) {
            return QImage();
        }

        QImage stage1;
        const uint8_t* data1 = rawImage1.data();
        QImage qImage1(data1, rawImage1.width(), rawImage1.height(),
                       rawImage1.stride(), QImage::Format_RGB888);
        stage1 = qImage1.copy();

        // 在后台线程转换为 base64，避免阻塞 UI
        QString base641 = imageToBase64(stage1);
        QMetaObject::invokeMethod(this, [this, base641]() {
            emit progressiveStageFinished(base641, 1, 3);
        }, Qt::QueuedConnection);

        // 阶段 2: 中等预览 (1280x720)
        if (m_cancelRequested.loadRelaxed()) {
            return stage1;
        }

        auto rawImage2 = m_processor.decodePreview(1280, 720);
        if (!rawImage2.isValid() || m_cancelRequested.loadRelaxed()) {
            return stage1;  // 返回阶段1的结果
        }

        QImage stage2;
        const uint8_t* data2 = rawImage2.data();
        QImage qImage2(data2, rawImage2.width(), rawImage2.height(),
                       rawImage2.stride(), QImage::Format_RGB888);
        stage2 = qImage2.copy();

        QString base642 = imageToBase64(stage2);
        QMetaObject::invokeMethod(this, [this, base642]() {
            emit progressiveStageFinished(base642, 2, 3);
        }, Qt::QueuedConnection);

        // 阶段 3: 全尺寸预览 (1920x1080)
        if (m_cancelRequested.loadRelaxed()) {
            return stage2;  // 返回阶段2的结果
        }

        auto rawImage3 = m_processor.decodePreview(1920, 1080);
        if (!rawImage3.isValid() || m_cancelRequested.loadRelaxed()) {
            return stage2;  // 返回阶段2的结果
        }

        const uint8_t* data3 = rawImage3.data();
        QImage qImage3(data3, rawImage3.width(), rawImage3.height(),
                       rawImage3.stride(), QImage::Format_RGB888);
        return qImage3.copy();
    });

    m_decodeWatcher.setFuture(future);
}

void RawProcessor::cancelDecode()
{
    if (isDecoding()) {
        m_cancelRequested = 1;
        m_decodeWatcher.waitForFinished();
        m_cancelRequested = 0;
        setDecoding(false);
    }
}

void RawProcessor::setAdjustments(float exposure, float contrast,
                                       float highlights, float shadows,
                                       float saturation, float temperature)
{
    PixRaw::RawAdjustments adjustments;
    adjustments.exposure = exposure;
    adjustments.contrast = contrast;
    adjustments.highlights = highlights;
    adjustments.shadows = shadows;
    adjustments.saturation = saturation;
    adjustments.temperature = temperature;

    m_processor.setAdjustments(adjustments);
}

void RawProcessor::redecodeWithAdjustments()
{
    if (!m_processor.isOpen()) {
        m_lastError = "No file opened";
        emit decodeFailed(m_lastError);
        return;
    }

    // 使用当前的调整参数重新解码
    decodeAsync(1920, 1080);
}

void RawProcessor::onDecodeFinished()
{
    if (m_cancelRequested.loadRelaxed()) {
        setDecoding(false);
        return;
    }

    QImage result = m_decodeWatcher.result();

    // 检查是否有错误
    if (result.isNull()) {
        QString error = QString::fromStdString(m_processor.getLastError());
        if (error.isEmpty()) {
            error = "Unknown decode error";
        }
        m_lastError = error;
        setDecoding(false);
        emit decodeFailed(error);
        return;
    }

    // 转换为 base64 并发送
    QString base64 = imageToBase64(result);
    emit decodeFinished(base64);
    setDecoding(false);
}

void RawProcessor::onProgressiveFinished()
{
    // 渐进式解码的最终处理
    if (!m_cancelRequested.loadRelaxed()) {
        QImage result = m_decodeWatcher.result();
        if (!result.isNull()) {
            QString base64 = imageToBase64(result);
            emit progressiveFinished(base64);
        }
    }
    setDecoding(false);
}

QString RawProcessor::imageToBase64(const QImage& image)
{
    if (image.isNull()) {
        return "";
    }

    QByteArray byteArray;
    QBuffer buffer(&byteArray);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "JPEG");  // 使用 JPEG 压缩

    QString base64 = QString::fromLatin1(byteArray.toBase64());
    return QString("data:image/jpeg;base64,") + base64;
}
