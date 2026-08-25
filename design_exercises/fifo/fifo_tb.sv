// **************************************************************************************
// @file fifo_tb.sv
// @brief fifo testbench.
// **************************************************************************************
// MIT License
//
// Copyright (c) 2026 Miguel Ugsimar
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.
// **************************************************************************************

// this is a simple exercise on how to create a testbench
//
// below are my notes about testbench. but there are a lot of things you will
// be missing out if you are just reading my notes below. i advice you read
//
// [System Verilog for verifcation: A guide to learning the testbench language
// feature by Chris Pear]
// 
// what is a testbench? a testbench contains multiple components. the basic
// building block of a testbench are:
//    1. Generator
//    2. Agent
//    3. Driver
//    4. Monitor
//    5. Checker
//    6. Scoreboard
//
// these components are clases modeled as `transactors`. and these components
// are instantiated and contained inside the `environment`.
//
//


