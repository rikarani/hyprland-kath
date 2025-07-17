# Hyprland Kath

cek blog resmi Hyprland [disini](https://hypr.land/news/contestWinners/)

# Instalasi

1. clone repo
   bebas clone dimana, di `~/Desktop` pun boleh

```bash
git clone https://github.com/rikarani/hyprland-kath
```

2. copy atau move bebas dah, saran ak move aj sih

```bash
sudo mv hyprland-kath /usr/share/sddm/themes
```

3. edit file `/etc/sddm.conf`

```bash
sudo nano /etc/sddm.conf
```

trus ubah jdi kek gini

```
[Theme]
Current=hyprland-kath
```

4. tambahin font

```bash
sudo mv ~/Desktop/hyprland-kath/Font/pixelon.regular.ttf /usr/local/share/fonts/ttf/Pixelon
```

klo blm ada, buat folderny dlu

```bash
sudo mkdir -p /usr/local/share/fonts/ttf/Pixelon
```

# Note

1. ak ngubah banyak hal

   - semua bagian ak jdiin satu di `Main.qml`
   - ngehapus banyak konfig, semua value ak hardcode

2. ada bug dibagian Select Session, bugnya tuh popup ny gmw muncul (gk terlalu ngaruh sih soalnya ak memang pke Hyprland yg uwsm-managed)

# Credit

[SDDM Astronaut Theme](https://github.com/Keyitdev/sddm-astronaut-theme) by [Keyitdev](https://github.com/Keyitdev)

cek aja reponya, ada banyak tema lain yg keren-keren
