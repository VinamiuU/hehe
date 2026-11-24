#!/usr/bin/env bash
# Đổi tên ảnh khách thành mã ngẫu nhiên, chép vào assets/guests/ và ghi bảng link.
#
# Cách dùng (chạy trong thư mục repo, bằng Terminal hoặc Git Bash):
#   bash add-guests.sh ../anh-goc
#
# Thư mục ảnh gốc nên nằm NGOÀI repo; mỗi ảnh đặt tên theo khách, ví dụ "Đức Phong.jpg".
# Chỉ bỏ ảnh của khách mới vào đó, chạy lại với ảnh cũ sẽ tạo mã mới và trùng lặp.
set -eu

SRC="${1:?Cách dùng: bash add-guests.sh <thư-mục-ảnh-gốc>}"
DEST="assets/guests"
BASE_URL="https://vinamiuu.github.io/hehe/"
LINKS_FILE="../guest-links.csv"   # nằm ngoài repo, không bị push

new_code() {
  LC_ALL=C tr -dc 'a-z0-9' </dev/urandom | head -c 12 || true
}

urlencode() {
  local LC_ALL=C s="$1" c out="" i
  for ((i = 0; i < ${#s}; i++)); do
    c="${s:i:1}"
    case "$c" in
      [a-zA-Z0-9._~-]) out+="$c" ;;
      *) out+=$(printf '%%%02X' "'$c") ;;
    esac
  done
  printf '%s' "$out"
}

mkdir -p "$DEST"
[ -s "$LINKS_FILE" ] || echo "Tên,Mã,Link" > "$LINKS_FILE"

shopt -s nullglob nocaseglob
count=0
for file in "$SRC"/*.jpg "$SRC"/*.jpeg; do
  name="$(basename "$file")"
  name="${name%.*}"

  code="$(new_code)"
  while [ -e "$DEST/$code.jpg" ]; do code="$(new_code)"; done

  cp "$file" "$DEST/$code.jpg"
  link="${BASE_URL}?g=${code}&to=$(urlencode "$name")"
  echo "\"$name\",$code,\"$link\"" >> "$LINKS_FILE"
  echo "✓ $name -> $DEST/$code.jpg"
  count=$((count + 1))
done

echo "Xong $count ảnh. Bảng link: $LINKS_FILE"
