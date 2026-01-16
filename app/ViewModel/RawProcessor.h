#ifndef RAWPROCESSOR_H
#define RAWPROCESSOR_H

#include <QObject>
#include <QString>
#include <QImage>
#include <QVariant>
#include <QFutureWatcher>
#include <QAtomicInt>
#include <PixRaw.h>
#include <RawAdjustments.h>

/**
 * @brief RAW 图像处理器类（Qt 层）
 *
 * 封装 PixRaw 库，提供 Qt/QML 友好的接口
 * 支持异步解码和渐进式加载
 */
class RawProcessor : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY fileChanged)
    Q_PROPERTY(bool fileOpen READ fileOpen NOTIFY fileChanged)
    Q_PROPERTY(bool decoding READ isDecoding NOTIFY decodingChanged)

public:
    explicit RawProcessor(QObject *parent = nullptr);
    ~RawProcessor();

    /**
     * @brief 打开 RAW 文件
     */
    Q_INVOKABLE bool openFile(const QString& filePath);

    /**
     * @brief 获取 RAW 文件的元数据
     */
    Q_INVOKABLE QVariantMap getMetadata() const;

    /**
     * @brief 解码 RAW 图像数据（同步）
     */
    Q_INVOKABLE QImage decodeImage();

    /**
     * @brief 获取超快速预览（320x240，用于立即显示）
     */
    Q_INVOKABLE QImage decodeQuickPreview();

    /**
     * @brief 获取中等预览（1280x720，用于平衡显示）
     */
    Q_INVOKABLE QImage decodeMediumPreview();

    /**
     * @brief 获取预览图的 Base64 编码
     */
    Q_INVOKABLE QString getPreviewBase64();

    /**
     * @brief 获取嵌入的缩略图
     */
    Q_INVOKABLE QImage getThumbnail();

    /**
     * @brief 获取缩略图的 Base64 编码
     */
    Q_INVOKABLE QString getThumbnailBase64();

    /**
     * @brief 获取最后的错误信息
     */
    Q_INVOKABLE QString getLastError() const;

    /**
     * @brief 检查是否有文件已打开
     */
    Q_INVOKABLE bool isFileOpen() const;

    /**
     * @brief 检查是否正在解码
     */
    Q_INVOKABLE bool isDecoding() const;

    /**
     * @brief 关闭当前打开的文件
     */
    Q_INVOKABLE void close();

    /**
     * @brief 异步解码图像（后台线程）
     * @param max_width 最大宽度（0表示自适应）
     * @param max_height 最大高度（0表示自适应）
     */
    Q_INVOKABLE void decodeAsync(int max_width = 1920, int max_height = 1080);

    /**
     * @brief 异步渐进式解码（逐步提高质量）
     * 会先发送快速预览，然后逐步提高质量
     */
    Q_INVOKABLE void decodeProgressive();

    /**
     * @brief 取消当前解码操作
     */
    Q_INVOKABLE void cancelDecode();

    /**
     * @brief 设置图像调整参数
     * @param exposure 曝光 (-2.0 ~ 2.0)
     * @param contrast 对比度 (-50 ~ 50)
     * @param highlights 高光 (-100 ~ 100)
     * @param shadows 阴影 (-100 ~ 100)
     * @param saturation 饱和度 (-100 ~ 100)
     * @param temperature 色温 (-100 ~ 100)
     */
    Q_INVOKABLE void setAdjustments(float exposure, float contrast,
                                     float highlights, float shadows,
                                     float saturation, float temperature);

    /**
     * @brief 重新解码并应用当前调整参数
     */
    Q_INVOKABLE void redecodeWithAdjustments();

    // Qt 属性访问器
    QString currentFile() const { return m_currentFile; }
    bool fileOpen() const { return m_fileOpen; }

signals:
    void fileChanged();
    void decodingChanged();

    /**
     * @brief 异步解码完成（Base64 格式）
     * @param base64Image 解码后的图像的 Base64 字符串
     */
    void decodeFinished(const QString& base64Image);

    /**
     * @brief 渐进式解码阶段完成（Base64 格式）
     * @param base64Image 当前阶段的图像的 Base64 字符串
     * @param stage 阶段编号（1=快速，2=中等，3=完整）
     * @param totalStages 总阶段数
     */
    void progressiveStageFinished(const QString& base64Image, int stage, int totalStages);

    /**
     * @brief 渐进式解码全部完成（Base64 格式）
     * @param base64Image 最终图像的 Base64 字符串
     */
    void progressiveFinished(const QString& base64Image);

    /**
     * @brief 解码失败
     * @param error 错误信息
     */
    void decodeFailed(const QString& error);

private slots:
    void onDecodeFinished();
    void onProgressiveFinished();

private:
    PixRaw::PixRaw m_processor;
    QString m_lastError;
    bool m_fileOpen = false;
    QString m_currentFile;

    // 异步解码支持
    QFutureWatcher<QImage> m_decodeWatcher;
    QAtomicInt m_cancelRequested;
    bool m_decoding = false;

    void setDecoding(bool decoding);
    QString imageToBase64(const QImage& image);
};

#endif // RAWPROCESSOR_H
