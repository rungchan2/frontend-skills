#!/usr/bin/env python3
"""
NPM 패키지 최신 버전 조회 스크립트

Usage:
    python get_npm_versions.py react next typescript
    python get_npm_versions.py --category frontend
    python get_npm_versions.py --all
"""

import argparse
import json
import subprocess
import sys
from concurrent.futures import ThreadPoolExecutor, as_completed

# 카테고리별 주요 패키지
PACKAGES = {
    "frontend": [
        "react",
        "react-dom",
        "next",
        "vue",
        "nuxt",
        "svelte",
        "@sveltejs/kit",
        "typescript",
        "vite",
    ],
    "styling": [
        "tailwindcss",
        "postcss",
        "autoprefixer",
        "sass",
        "@emotion/react",
        "@emotion/styled",
        "styled-components",
    ],
    "ui": [
        "@radix-ui/react-dialog",
        "@radix-ui/react-dropdown-menu",
        "@headlessui/react",
        "@mui/material",
        "@chakra-ui/react",
        "antd",
    ],
    "state": [
        "zustand",
        "jotai",
        "recoil",
        "@reduxjs/toolkit",
        "react-redux",
        "@tanstack/react-query",
        "swr",
    ],
    "forms": [
        "react-hook-form",
        "zod",
        "yup",
        "@hookform/resolvers",
    ],
    "backend": [
        "express",
        "fastify",
        "hono",
        "@nestjs/core",
        "prisma",
        "drizzle-orm",
        "@trpc/server",
        "@trpc/client",
    ],
    "testing": [
        "vitest",
        "jest",
        "@testing-library/react",
        "playwright",
        "@playwright/test",
        "cypress",
    ],
    "utils": [
        "axios",
        "date-fns",
        "dayjs",
        "lodash",
        "uuid",
        "nanoid",
        "clsx",
        "class-variance-authority",
    ],
    "icons": [
        "lucide-react",
        "@heroicons/react",
        "@phosphor-icons/react",
        "react-icons",
    ],
}


def get_npm_version(package_name: str) -> dict:
    """NPM 레지스트리에서 패키지 최신 버전 조회"""
    try:
        result = subprocess.run(
            ["curl", "-s", f"https://registry.npmjs.org/{package_name}/latest"],
            capture_output=True,
            text=True,
            timeout=10,
        )
        if result.returncode == 0:
            data = json.loads(result.stdout)
            return {
                "name": package_name,
                "version": data.get("version", "unknown"),
                "description": data.get("description", "")[:60],
            }
    except Exception as e:
        pass
    return {"name": package_name, "version": "error", "description": ""}


def get_versions_parallel(packages: list[str]) -> list[dict]:
    """병렬로 여러 패키지 버전 조회"""
    results = []
    with ThreadPoolExecutor(max_workers=10) as executor:
        futures = {executor.submit(get_npm_version, pkg): pkg for pkg in packages}
        for future in as_completed(futures):
            results.append(future.result())
    # 입력 순서대로 정렬
    pkg_order = {pkg: i for i, pkg in enumerate(packages)}
    results.sort(key=lambda x: pkg_order.get(x["name"], 999))
    return results


def print_results(results: list[dict], format: str = "table"):
    """결과 출력"""
    if format == "json":
        print(json.dumps(results, indent=2))
    elif format == "markdown":
        print("| 패키지명 | 버전 | 설명 |")
        print("|---------|------|------|")
        for r in results:
            print(f"| {r['name']} | {r['version']} | {r['description']} |")
    else:  # table
        print(f"{'패키지명':<35} {'버전':<12} 설명")
        print("-" * 80)
        for r in results:
            print(f"{r['name']:<35} {r['version']:<12} {r['description']}")


def main():
    parser = argparse.ArgumentParser(description="NPM 패키지 최신 버전 조회")
    parser.add_argument("packages", nargs="*", help="조회할 패키지 이름들")
    parser.add_argument(
        "--category",
        "-c",
        choices=list(PACKAGES.keys()),
        help="카테고리별 패키지 조회",
    )
    parser.add_argument("--all", "-a", action="store_true", help="모든 카테고리 조회")
    parser.add_argument(
        "--format",
        "-f",
        choices=["table", "json", "markdown"],
        default="table",
        help="출력 형식",
    )
    parser.add_argument("--list", "-l", action="store_true", help="카테고리 목록 출력")

    args = parser.parse_args()

    if args.list:
        print("사용 가능한 카테고리:")
        for cat, pkgs in PACKAGES.items():
            print(f"  {cat}: {', '.join(pkgs[:3])}...")
        return

    packages = []

    if args.all:
        for cat, pkgs in PACKAGES.items():
            print(f"\n## {cat.upper()}")
            results = get_versions_parallel(pkgs)
            print_results(results, args.format)
        return

    if args.category:
        packages = PACKAGES.get(args.category, [])
    elif args.packages:
        packages = args.packages
    else:
        parser.print_help()
        return

    if packages:
        results = get_versions_parallel(packages)
        print_results(results, args.format)


if __name__ == "__main__":
    main()
