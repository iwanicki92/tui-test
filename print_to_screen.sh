source ./ui_misc.sh

echo "This will not be visible"
echo "This will also not be visible" >&2
ui_echo "123"
ui_echo "123"
sleep 1
ui_echo "123456789abcdefgi jkl!@#$%^&*; '1234567 89abcdefg ijkl!@ #$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_echo "123456789abcdefgijkl!@#$%^&*;'123456789abcdefgijkl!@#$%^&*;'"
ui_read -p "Your Choice [y/n]: "
ui_echo "123"
ui_echo "123"
ui_echo "123"
ui_echo "123"
