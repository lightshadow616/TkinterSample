
# 示例1： tkinter 显示一个窗口
# import tkinter as tk
# from tkinter import messagebox

# # 1. 创建主窗口
# root = tk.Tk()
# root.title("我的第一个Tkinter程序")
# root.geometry("300x200")  # 设置窗口宽300，高200

# # 2. 定义按钮点击事件


# def show_message():
#     messagebox.showinfo("提示", "Hello, Tkinter!")


# # 3. 创建并摆放组件
# label = tk.Label(root, text="欢迎使用Tkinter", font=("Arial", 12))
# label.pack(pady=20)  # 使用pack布局，垂直方向留白20

# button = tk.Button(root, text="点击我", command=show_message)
# button.pack()

# # 4. 进入主事件循环（让窗口持续显示）
# root.mainloop()

# 全屏图片显示应用
import tkinter as tk
from PIL import Image, ImageTk
import json
import os
import sys

# 修复 PyInstaller 打包后 PIL._tkinter_finder 找不到的问题
try:
    import PIL._tkinter_finder
except ImportError:
    pass


def get_resource_path(relative_path):
    """获取资源文件的绝对路径（支持打包后的程序）"""
    app_dir = get_app_dir()
    
    # 展开 ~ 为用户主目录
    expanded_path = os.path.expanduser(relative_path)
    
    # 如果展开后是绝对路径，直接返回
    if os.path.isabs(expanded_path):
        return expanded_path
    
    # 否则，与应用目录拼接
    return os.path.join(app_dir, expanded_path)


def get_app_dir():
    """获取应用所在目录（支持打包后的程序）"""
    if getattr(sys, 'frozen', False):
        # PyInstaller 打包后，使用可执行文件所在目录
        return os.path.dirname(sys.executable)
    # 开发环境或源码运行，使用脚本所在目录
    return os.path.dirname(os.path.abspath(__file__))


def load_config():
    """加载配置文件（优先读取外部配置文件）"""
    default_config = {
        "image_path": "sample.jpg",
        "window_title": "图片查看器"
    }

    app_dir = get_app_dir()
    
    # 配置搜索路径（按优先级排序）
    # 1. 可执行文件/应用目录（最高优先级）
    # 2. 用户配置目录
    # 3. 系统配置目录
    # 4. 当前工作目录（最低优先级）
    config_paths = [
        os.path.join(app_dir, "config.json"),
        os.path.join(os.path.expanduser("~/.local/share/applications/image-viewer"), "config.json"),
        "/opt/image-viewer/config.json",
        os.path.join(os.getcwd(), "config.json")
    ]

    config_path = None
    for path in config_paths:
        if os.path.exists(path):
            config_path = path
            break

    if config_path:
        try:
            print(f"使用配置文件: {config_path}")
            with open(config_path, 'r', encoding='utf-8') as f:
                config = json.load(f)
                default_config.update(config)
        except Exception as e:
            print(f"加载配置文件失败: {e}，使用默认配置")
    else:
        print("未找到配置文件，使用默认配置")

    return default_config


def resize_image(event, img, label):
    """窗口大小变化时自动调整图片大小"""
    # 获取当前窗口大小
    window_width = event.width
    window_height = event.height

    # 计算缩放比例（保持宽高比）
    img_width, img_height = img.size
    scale_w = window_width / img_width
    scale_h = window_height / img_height
    scale = min(scale_w, scale_h, 1.0)  # 不放大，只缩小

    new_width = int(img_width * scale)
    new_height = int(img_height * scale)

    # 调整图片大小
    resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)
    tk_image = ImageTk.PhotoImage(resized_img)

    # 更新标签
    label.config(image=tk_image)
    label.image = tk_image  # 保持引用


# 1. 加载配置
config = load_config()

# 2. 创建主窗口
root = tk.Tk()
root.title(config["window_title"])

# 2.1. 获取屏幕的宽度和高度（单位：像素）
screen_width = root.winfo_screenwidth()
screen_height = root.winfo_screenheight()
root.geometry(f"{screen_width}x{screen_height}")

# 设置全屏模式
root.attributes('-fullscreen', True)

print(f"当前屏幕分辨率为: {screen_width} x {screen_height}")

# 3. 加载图片
image_path = get_resource_path(config["image_path"])

try:
    img = Image.open(image_path)
    print(f"成功加载图片: {image_path}")
    print(f"图片原始尺寸: {img.size}")
except Exception as e:
    print(f"无法加载图片: {e}")
    print("请检查 config.json 中的 image_path 配置是否正确")
    # 创建一个空白图像作为占位符
    img = Image.new('RGB', (800, 600), color='gray')

# 4. 初始显示图片（根据窗口大小调整）
window_width = screen_width
window_height = screen_height
img_width, img_height = img.size
scale_w = window_width / img_width
scale_h = window_height / img_height
scale = min(scale_w, scale_h, 1.0)

new_width = int(img_width * scale)
new_height = int(img_height * scale)
resized_img = img.resize((new_width, new_height), Image.Resampling.LANCZOS)

# 5. 将 Pillow 图片转换为 Tkinter PhotoImage 对象
tk_image = ImageTk.PhotoImage(resized_img)

# 6. 创建 Label 标签来显示图片
label = tk.Label(root, image=tk_image)
label.pack(expand=True, fill=tk.BOTH)
label.image = tk_image  # 保持引用防止被垃圾回收

# 7. 绑定窗口大小变化事件
root.bind('<Configure>', lambda e: resize_image(e, img, label))

# 8. 按 ESC 键退出全屏


def exit_fullscreen(event=None):
    root.destroy()


root.bind('<Escape>', exit_fullscreen)

# 9. 进入主事件循环
root.mainloop()
