import tkinter as tk
from tkinter import ttk
import os

class SimpleDarkApp:
    def __init__(self):
        self.root = tk.Tk()
        self.root.title("Простое тёмное приложение")
        self.root.configure(bg='#2d2d30')
        
        # Стили для тёмной темы
        style = ttk.Style()
        style.theme_use('clam')
        
        # Настройка цветов
        dark_bg = '#2d2d30'
        dark_fg = '#ffffff'
        dark_button = '#3e3e42'
        
        style.configure('TLabel', background=dark_bg, foreground=dark_fg)
        style.configure('TButton', 
                       background=dark_button, 
                       foreground=dark_fg,
                       borderwidth=0,
                       relief='flat')
        
        # Если у вас есть GIF, загрузите его
        self.load_gif()
        
        # Запуск
        self.root.mainloop()
    
    def load_gif(self):
        """Загрузка GIF (если он есть)"""
        try:
            # Для работы с GIF нужен PIL
            from PIL import Image, ImageTk
            
            gif_path = "/data929G/br\ br\ windows\ 7/wallpapper/1741441663_new_video.gif"
            if os.path.exists(gif_path):
                self.gif = Image.open(gif_path)
                self.frames = []
                
                # Загрузка кадров
                for frame in range(self.gif.n_frames):
                    self.gif.seek(frame)
                    self.frames.append(ImageTk.PhotoImage(self.gif))
                
                # Создание Label для GIF
                self.label = ttk.Label(self.root)
                self.label.pack(pady=20)
                
                # Запуск анимации
                self.animate(0)
        except ImportError:
            print("Установите PIL: pip install Pillow")
        except Exception as e:
            print(f"Ошибка загрузки GIF: {e}")
    
    def animate(self, counter):
        """Анимация GIF"""
        if hasattr(self, 'frames'):
            # Показываем текущий кадр
            frame = self.frames[counter]
            self.label.configure(image=frame)
            
            # Следующий кадр
            counter = (counter + 1) % len(self.frames)
            
            # Запускаем следующий кадр
            self.root.after(100, self.animate, counter)

# Запуск
if __name__ == "__main__":
    SimpleDarkApp()