#!/usr/bin/env python3
"""
컬러 팔레트 생성 스크립트

Primary 색상 하나로 전체 디자인 시스템 컬러 팔레트를 생성한다.

Usage:
    python generate_palette.py "#3B82F6"
    python generate_palette.py "#3B82F6" --format tailwind
    python generate_palette.py "#3B82F6" --format css
    python generate_palette.py "#3B82F6" --with-semantic
"""

import argparse
import colorsys
import json
import re


def hex_to_rgb(hex_color: str) -> tuple[int, int, int]:
    """HEX를 RGB로 변환"""
    hex_color = hex_color.lstrip("#")
    return tuple(int(hex_color[i : i + 2], 16) for i in (0, 2, 4))


def rgb_to_hex(r: int, g: int, b: int) -> str:
    """RGB를 HEX로 변환"""
    return f"#{r:02X}{g:02X}{b:02X}"


def rgb_to_hsl(r: int, g: int, b: int) -> tuple[float, float, float]:
    """RGB를 HSL로 변환"""
    r, g, b = r / 255.0, g / 255.0, b / 255.0
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    return h * 360, s * 100, l * 100


def hsl_to_rgb(h: float, s: float, l: float) -> tuple[int, int, int]:
    """HSL을 RGB로 변환"""
    h, s, l = h / 360, s / 100, l / 100
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return int(r * 255), int(g * 255), int(b * 255)


def generate_shade(hex_color: str, lightness_target: float) -> str:
    """특정 밝기로 색상 생성"""
    r, g, b = hex_to_rgb(hex_color)
    h, s, l = rgb_to_hsl(r, g, b)
    # 채도 약간 조정 (밝을수록 채도 낮게, 어두울수록 채도 높게)
    s_adjusted = s * (0.8 + 0.4 * (1 - lightness_target / 100))
    s_adjusted = min(100, max(0, s_adjusted))
    new_r, new_g, new_b = hsl_to_rgb(h, s_adjusted, lightness_target)
    return rgb_to_hex(new_r, new_g, new_b)


def generate_primary_palette(hex_color: str) -> dict[str, str]:
    """Primary 색상에서 전체 팔레트 생성"""
    # 밝기 레벨 (50이 가장 밝고, 900이 가장 어두움)
    lightness_map = {
        "50": 97,
        "100": 94,
        "200": 86,
        "300": 76,
        "400": 64,
        "500": 50,  # 기본 색상
        "600": 42,
        "700": 34,
        "800": 26,
        "900": 18,
        "950": 10,
    }

    palette = {}
    for shade, lightness in lightness_map.items():
        palette[shade] = generate_shade(hex_color, lightness)

    return palette


def generate_complementary(hex_color: str) -> str:
    """보색 생성"""
    r, g, b = hex_to_rgb(hex_color)
    h, s, l = rgb_to_hsl(r, g, b)
    h_comp = (h + 180) % 360
    new_r, new_g, new_b = hsl_to_rgb(h_comp, s, l)
    return rgb_to_hex(new_r, new_g, new_b)


def generate_analogous(hex_color: str) -> list[str]:
    """유사색 생성 (±30도)"""
    r, g, b = hex_to_rgb(hex_color)
    h, s, l = rgb_to_hsl(r, g, b)

    colors = []
    for offset in [-30, 30]:
        h_new = (h + offset) % 360
        new_r, new_g, new_b = hsl_to_rgb(h_new, s, l)
        colors.append(rgb_to_hex(new_r, new_g, new_b))

    return colors


def get_semantic_colors() -> dict[str, dict]:
    """시맨틱 컬러 (고정값)"""
    return {
        "success": {
            "light": "#DCFCE7",
            "main": "#22C55E",
            "dark": "#16A34A",
        },
        "warning": {
            "light": "#FEF3C7",
            "main": "#F59E0B",
            "dark": "#D97706",
        },
        "error": {
            "light": "#FEE2E2",
            "main": "#EF4444",
            "dark": "#DC2626",
        },
        "info": {
            "light": "#DBEAFE",
            "main": "#3B82F6",
            "dark": "#2563EB",
        },
    }


def get_neutral_colors() -> dict[str, str]:
    """뉴트럴 컬러 (Gray Scale)"""
    return {
        "50": "#F9FAFB",
        "100": "#F3F4F6",
        "200": "#E5E7EB",
        "300": "#D1D5DB",
        "400": "#9CA3AF",
        "500": "#6B7280",
        "600": "#4B5563",
        "700": "#374151",
        "800": "#1F2937",
        "900": "#111827",
        "950": "#030712",
    }


def format_tailwind(primary: dict, secondary: dict, neutral: dict, semantic: dict) -> str:
    """Tailwind CSS 설정 형식으로 출력"""
    config = {
        "colors": {
            "primary": primary,
            "secondary": secondary,
            "gray": neutral,
            **{k: v["main"] for k, v in semantic.items()},
        }
    }
    return f"""// tailwind.config.js
module.exports = {{
  theme: {{
    extend: {{
      colors: {json.dumps(config['colors'], indent=8)}
    }}
  }}
}}"""


def format_css(primary: dict, secondary: dict, neutral: dict, semantic: dict) -> str:
    """CSS 변수 형식으로 출력"""
    lines = [":root {"]

    lines.append("  /* Primary */")
    for shade, color in primary.items():
        lines.append(f"  --color-primary-{shade}: {color};")

    lines.append("\n  /* Secondary */")
    for shade, color in secondary.items():
        lines.append(f"  --color-secondary-{shade}: {color};")

    lines.append("\n  /* Neutral */")
    for shade, color in neutral.items():
        lines.append(f"  --color-gray-{shade}: {color};")

    lines.append("\n  /* Semantic */")
    for name, variants in semantic.items():
        for variant, color in variants.items():
            lines.append(f"  --color-{name}-{variant}: {color};")

    lines.append("}")
    return "\n".join(lines)


def format_markdown(primary: dict, secondary: dict, neutral: dict, semantic: dict) -> str:
    """마크다운 테이블 형식으로 출력"""
    lines = ["## Primary Colors", "| Shade | HEX |", "|-------|-----|"]
    for shade, color in primary.items():
        lines.append(f"| {shade} | {color} |")

    lines.extend(["", "## Secondary Colors", "| Shade | HEX |", "|-------|-----|"])
    for shade, color in secondary.items():
        lines.append(f"| {shade} | {color} |")

    lines.extend(["", "## Neutral Colors (Gray)", "| Shade | HEX |", "|-------|-----|"])
    for shade, color in neutral.items():
        lines.append(f"| {shade} | {color} |")

    lines.extend(["", "## Semantic Colors", "| Name | Light | Main | Dark |", "|------|-------|------|------|"])
    for name, variants in semantic.items():
        lines.append(f"| {name} | {variants['light']} | {variants['main']} | {variants['dark']} |")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="컬러 팔레트 생성")
    parser.add_argument("color", help="Primary HEX 색상 (예: #3B82F6)")
    parser.add_argument(
        "--format",
        "-f",
        choices=["tailwind", "css", "markdown", "json"],
        default="markdown",
        help="출력 형식",
    )
    parser.add_argument(
        "--secondary",
        "-s",
        help="Secondary HEX 색상 (미지정 시 보색 자동 생성)",
    )
    parser.add_argument(
        "--with-semantic",
        action="store_true",
        help="시맨틱 컬러 포함",
    )

    args = parser.parse_args()

    # HEX 색상 검증
    if not re.match(r"^#?[0-9A-Fa-f]{6}$", args.color):
        print(f"오류: 올바른 HEX 색상을 입력하세요 (예: #3B82F6)")
        return

    primary_hex = args.color if args.color.startswith("#") else f"#{args.color}"

    # 팔레트 생성
    primary = generate_primary_palette(primary_hex)

    # Secondary 색상 (지정되지 않으면 보색 사용)
    if args.secondary:
        secondary_hex = args.secondary if args.secondary.startswith("#") else f"#{args.secondary}"
    else:
        secondary_hex = generate_complementary(primary_hex)
    secondary = generate_primary_palette(secondary_hex)

    neutral = get_neutral_colors()
    semantic = get_semantic_colors() if args.with_semantic else {}

    # 출력
    if args.format == "tailwind":
        print(format_tailwind(primary, secondary, neutral, semantic))
    elif args.format == "css":
        print(format_css(primary, secondary, neutral, semantic))
    elif args.format == "json":
        result = {
            "primary": primary,
            "secondary": secondary,
            "neutral": neutral,
        }
        if semantic:
            result["semantic"] = semantic
        print(json.dumps(result, indent=2))
    else:  # markdown
        print(format_markdown(primary, secondary, neutral, semantic))

    # 추가 정보
    print(f"\n---\nPrimary: {primary_hex}")
    print(f"Secondary (보색): {secondary_hex}")
    analogous = generate_analogous(primary_hex)
    print(f"유사색: {analogous[0]}, {analogous[1]}")


if __name__ == "__main__":
    main()
