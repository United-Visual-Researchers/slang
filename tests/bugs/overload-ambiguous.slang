// https://github.com/shader-slang/slang/issues/4476

//TEST(compute):COMPARE_COMPUTE_EX(filecheck-buffer=BUF):-cuda -compute -shaderobj
//TEST(compute):COMPARE_COMPUTE_EX(filecheck-buffer=BUF):-cpu -compute -shaderobj
//TEST(compute):COMPARE_COMPUTE_EX(filecheck-buffer=BUF):-slang -compute -shaderobj
//TEST(compute):COMPARE_COMPUTE_EX(filecheck-buffer=BUF):-slang -compute -dx12 -shaderobj
//TEST(compute, vulkan):COMPARE_COMPUTE_EX(filecheck-buffer=BUF):-vk -compute -shaderobj

//TEST_INPUT:ubuffer(data=[0 0], stride=4):out,name=outputBuffer
RWStructuredBuffer<uint> outputBuffer;


uint getData()
{
    return 1u;
}

struct DataObtainer
{
    uint data;
    uint getData()
    {
        return data;
    }

    uint getValue()
    {
        return getData(); // will call DataObtainer::getData()
    }

    uint getValue2()
    {
        return ::getData(); // will call global getData()
    }
}

RWStructuredBuffer<uint> output;

[numthreads(1, 1, 1)]
[shader("compute")]
void computeMain(uint3 threadID: SV_DispatchThreadID)
{
    DataObtainer obtainer = {2u};
    outputBuffer[0] = obtainer.getValue();
    outputBuffer[1] = obtainer.getValue2();
    // BUF: 2
    // BUF-NEXT: 1
}
