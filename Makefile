AR=ar
LD_SHARED=g++

ARFLAGS=rcsv
SOFLAGS=-shared

LIB_OBJECTS = -L$(CUDAPATH)/lib64 -I$(CUDAPATH)/include -lcudart
CUDA_OBJECTS := probGpu.o

%.o : %.cu
	nvcc $(SIZE_FLAG) \
		-gencode arch=compute_52,code=sm_52 \
		-gencode arch=compute_60,code=sm_60 \
		-gencode arch=compute_61,code=sm_61 \
		-gencode arch=compute_70,code=sm_70 \
		-gencode arch=compute_75,code=sm_75 \
		-gencode arch=compute_80,code=sm_80 \
		-gencode arch=compute_86,code=sm_86 \
		-gencode arch=compute_86,code=compute_86 \
                -prec-sqrt=false -use_fast_math -O3 -Werror cross-execution-space-call \
                -Xptxas "-allow-expensive-optimizations=true -fmad=true -O3 -warn-lmem-usage -warn-spills" \
                -Xcompiler "-fpic -O3 -Wall -Wextra -Werror -Wno-error=unused-parameter" -c $<

libProbGPU: libProbGPU.a libProbGPU.so

libProbGPU.a: $(CUDA_OBJECTS) 
	$(AR) $(ARFLAGS) $@ $^

libProbGPU.so: libProbGPU.a $(CUDA_OBJECTS)
	$(LD_SHARED) $(SOFLAGS) $^ -o $@ $(LIB_OBJECTS)

clean:
	rm -f *.o
	rm -f *~
	rm -f *.a
	rm -f *.so

