# Parameters:
#   $1: divider charactor
function print_divider() {
    if [[ $# == 0 ]]; then
        eval "printf '%.0s'= {1..$(tput cols)}"     # 输出: 和窗口一样长的======
    else
        eval "printf '%.0s'$1 {1..$((  $(tput cols) / ${#1}  ))}"
    fi
}


# Parameters:
#   $1: output string
# FixMe:
#   can not work well
function center_print() {
    if [[ -p /dev/stdin ]]; then                # <-- make pipe work
        declare -r _str=$(cat -)                 # <-- make pipe work
    else
        declare -r _str=$1
    fi

    if [[ $OS == 'MacOS' ]]; then
        # for BSD
        echo $_str | fmt -c -w $(tput cols)
    else
        # for Linux
        declare -r _space_count=$((   $(tput cols) / 2   ))
        echo $_str | sed -e :a -e "s/^.\{1,$_space_count\}$/ &/;ta" -e 's/\(*\)\1/\1/'
    fi
}


# Parameters:
#   $1: color code. 0~255
#   $2: output string
#   -n: make sure it is the last parameter. use -n option of echo.
#
# 16色
#   格式: \033[属性;前景色;背景色m
#   属性
#       0:リセット, 1:太字, 2:低輝度, 3:イタリック, 4:下線, 5:点滅, 6:高速点滅, 7:反転, 8:非表示, 9:取り消し線
#       21:二重下線, 22:太字・低輝度解除, 23:イタリック解除, 24:下線解除, 25:点滅解除, 27:反転解除, 28:非表示解除, 29:取り消し線解除
#   前景色 - ()の中は明るい色
#       30(90)黒, 31(91)赤, 32(92)緑, 33(93)黄, 34(94)青, 35(95)紫, 36(96)水, 37(97)白, 38拡張色, 39標準色
#   背景色 - ()の中は明るい色
#       40(100)黒, 41(101)赤, 42(102)緑, 43(103)黄, 44(104)青, 45(105)紫, 46(106)水, 47(107)白, 48拡張色, 49標準色
#
# 256色
#   格式: \033[属性;前景色;背景色m
#       前景色 38;5;色番号
#       背景色 48;5;色番号
#   颜色范围
#       0-7：標準色8色             （\033[30m - \033[37m と同じ）
#       8-15：明るい色8色           （\033[90m - \033[97m と同じ）
#       16-231：各色（赤・緑・青） 6 段階、6×6×6=216色
#       232-255：グレースケール、24色
#
# 全てリセット
#   格式: \033[m  或者  \033[0m
#
# References:
#   https://qiita.com/ko1nksm/items/095bdb8f0eca6d327233
#   https://qiita.com/dojineko/items/49aa30018bb721b0b4a9
function color_print() {
    declare -r _esc=$(printf "\033")    # 更改输出颜色用的前缀
    declare -r _reset="${_esc}[0m"       # 重置所有颜色，字体设定

    if [[ $# == 0 ]] || [[ $# == 1 && ! -p /dev/stdin ]]; then
        echo "${_esc}[1;38;5;9m[Error] 参数数量错误. 用法: color_print 颜色 字符串${_esc}[m"
        exit 1;
    fi

    if [[ -p /dev/stdin ]]; then       # <-- make pipe work
        declare -r _str=$(cat -)        # <-- make pipe work
    else
        declare -r _str=$2
    fi

    declare _prefix=''
    case $1 in
    'info')
        declare -r _color=10
        _prefix='[Info] '
        ;;
    'error')
        declare -r _color=9
        _prefix='[Error] '
        ;;
    *)
        declare -r _color=$1
        ;;
    esac

    if echo $@ | grep ' \-n' > /dev/null 2>&1; then
        echo -n "${_esc}[38;5;${_color}m${_prefix}${_str}${_reset}"
    else
        echo "${_esc}[38;5;${_color}m${_prefix}${_str}${_reset}"
    fi
}


# Parameters:
#   $1: seconds
#   dot: make sure it is the last parameter. output dot instead number.
function count_down() {
    if echo $@ | grep 'dot' > /dev/null 2>&1; then
        for i in $(seq $1 -1 1); do
            echo -n '.' | color_print 102 -n
            sleep 1
        done
        echo ''
    else
        for i in $(seq $1 -1 1); do
            echo -n "$i " | color_print 102 -n
            sleep 1
        done
        color_print 102 '0'
    fi
}
