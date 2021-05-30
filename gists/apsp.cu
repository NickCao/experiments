#include "apsp.h"

const int b = 32;

namespace {
__global__ void kernel1(int n, int *graph, int p) {
  __shared__ int block[b * b];
  auto i = p * b + threadIdx.y;
  auto j = p * b + threadIdx.x;
  auto flag = i < n && j < n;
  block[threadIdx.y * b + threadIdx.x] = flag ? graph[i * n + j] : 10001;
  __syncthreads();
  if (flag) {
    for (int k = 0; k < b; k++) {
      block[threadIdx.y * b + threadIdx.x] =
          min(block[threadIdx.y * b + threadIdx.x],
              block[threadIdx.y * b + k] + block[k * b + threadIdx.x]);
    }
    graph[i * n + j] = block[threadIdx.y * b + threadIdx.x];
  }
}

__global__ void kernel2(int n, int *graph, int p) {
  __shared__ int block[b * b];
  __shared__ int center[b * b];
  auto i = p * b + threadIdx.y;
  auto j = p * b + threadIdx.x;
  auto ti = blockIdx.y * blockDim.y + threadIdx.y;
  auto tj = blockIdx.x * blockDim.x + threadIdx.x;
  bool flag = (blockIdx.x == p || blockIdx.y == p) &&
              !(blockIdx.x == p && blockIdx.y == p);
  if (flag) {
    if (i < n && j < n)
      center[threadIdx.y * b + threadIdx.x] = graph[i * n + j];
    else
      center[threadIdx.y * b + threadIdx.x] = 10001;
    if (ti < n && tj < n)
      block[threadIdx.y * b + threadIdx.x] = graph[ti * n + tj];
    else
      flag = false;
  }
  __syncthreads();
  if (flag) {
    if (blockIdx.x == p) {
      for (int k = 0; k < b; k++) {
        block[threadIdx.y * b + threadIdx.x] =
            min(block[threadIdx.y * b + threadIdx.x],
                block[threadIdx.y * b + k] + center[k * b + threadIdx.x]);
      }
    } else {
      for (int k = 0; k < b; k++) {
        block[threadIdx.y * b + threadIdx.x] =
            min(block[threadIdx.y * b + threadIdx.x],
                center[threadIdx.y * b + k] + block[k * b + threadIdx.x]);
      }
    }
    graph[ti * n + tj] = block[threadIdx.y * b + threadIdx.x];
  }
}

__global__ void kernel3(int n, int *graph, int p) {
  __shared__ int crossx[b * b];
  __shared__ int crossy[b * b];
  auto ix = p * b + threadIdx.y;
  auto jx = blockIdx.x * blockDim.x + threadIdx.x;
  auto iy = blockIdx.y * blockDim.y + threadIdx.y;
  auto jy = p * b + threadIdx.x;
  auto i = blockIdx.y * blockDim.y + threadIdx.y;
  auto j = blockIdx.x * blockDim.x + threadIdx.x;
  int me;
  bool flag = (blockIdx.x != p && blockIdx.y != p);
  if (flag) {
    if (ix < n && jx < n) {
      crossx[threadIdx.y * b + threadIdx.x] = graph[ix * n + jx];
    } else {
      crossx[threadIdx.y * b + threadIdx.x] = 10001;
    }
    if (iy < n && jy < n) {
      crossy[threadIdx.y * b + threadIdx.x] = graph[iy * n + jy];
    } else {
      crossy[threadIdx.y * b + threadIdx.x] = 10001;
    }
    if (i < n && j < n) {
      me = graph[i * n + j];
    } else {
      flag = false;
    }
  }
  __syncthreads();
  if (flag) {
    for (int k = 0; k < b; k++) {
      me = min(me, crossy[threadIdx.y * b + k] + crossx[k * b + threadIdx.x]);
    }
    graph[i * n + j] = me;
  }
}
} // namespace

void apsp(int n, int *graph) {
  int blocks = (n - 1) / b + 1;
  for (int p = 0; p < blocks; p++) {
    dim3 thr(b, b);
    dim3 blk0(1, 1);
    kernel1<<<blk0, thr>>>(n, graph, p);
    dim3 blk1(blocks, blocks);
    kernel2<<<blk1, thr>>>(n, graph, p);
    kernel3<<<blk1, thr>>>(n, graph, p);
  }
}
