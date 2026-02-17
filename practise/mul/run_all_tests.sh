#!/bin/bash

# ============================================================================
# 乘法器完整测试脚本
# 运行所有测试用例并生成报告
# ============================================================================

echo "============================================================"
echo "乘法器完整测试套件"
echo "============================================================"
echo ""

# 颜色定义
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 测试结果统计
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0

# ============================================================================
# 运行完整测试 (tb.v - 包含基础和扩展测试)
# ============================================================================
echo "------------------------------------------------------------"
echo "运行完整测试 (tb.v)"
echo "------------------------------------------------------------"

make -f Makefile.tb clean > /dev/null 2>&1
make -f Makefile.tb all

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ 测试编译和运行成功${NC}"

    # 统计测试结果
    if [ -f test.log ]; then
        PASS_COUNT=$(grep -c "\[PASS\]" test.log)
        FAIL_COUNT=$(grep -c "\[FAIL\]" test.log)
        TOTAL_TESTS=$((TOTAL_TESTS + PASS_COUNT + FAIL_COUNT))
        PASSED_TESTS=$((PASSED_TESTS + PASS_COUNT))
        FAILED_TESTS=$((FAILED_TESTS + FAIL_COUNT))

        echo "  通过: $PASS_COUNT"
        echo "  失败: $FAIL_COUNT"
    fi
else
    echo -e "${RED}✗ 测试失败${NC}"
fi

echo ""

# ============================================================================
# 生成测试报告
# ============================================================================
echo "============================================================"
echo "测试总结"
echo "============================================================"
echo "总测试数: $TOTAL_TESTS"
echo "通过数量: $PASSED_TESTS"
echo "失败数量: $FAILED_TESTS"

if [ $TOTAL_TESTS -gt 0 ]; then
    PASS_RATE=$(echo "scale=2; $PASSED_TESTS * 100 / $TOTAL_TESTS" | bc)
    echo "通过率: ${PASS_RATE}%"
fi

echo "============================================================"

if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}✓ 所有测试通过！乘法器功能正确${NC}"
    exit 0
else
    echo -e "${RED}✗ 发现 $FAILED_TESTS 个错误，需要调试${NC}"
    echo ""
    echo "详细日志: test.log"
    exit 1
fi
