import numpy as np
import cupy as cp
# import fly_rust_lib


def add(a, b):
    """Addition function"""
    return a + b


def subtract(a, b):
    """Subtraction function"""
    return a - b


def multiply(a, b):
    """Multiplication function"""
    return a * b


def divide(a, b):
    """Division function"""
    if b == 0:
        raise ValueError("Cannot divide by zero")
    return a / b


def compute_cpu(a: int, b: int):
    arr = np.random.rand(a, b)
    return np.sum(arr ** 2)


def compute_gpu(a: int, b: int):
    arr = cp.random.rand(a, b)
    return cp.sum(arr ** 2)


# def add_rust(a: int, b: int) -> int:
#     return int(fly_rust_lib.sum_as_string(a, b))
