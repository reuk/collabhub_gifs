import subprocess
import os

def main():
    for i in ["collabhub_gif_1", "collabhub_gif_2", "collabhub_gif_3",]:
        subprocess.call([
            "convert",
            "-loop",
            "0",
            "-delay",
            "3",
            os.path.join(i, "render", "*.png"),
            os.path.join(i, "out.gif"),
            ])

if __name__ == "__main__":
    main()
