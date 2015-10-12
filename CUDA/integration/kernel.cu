#include <thrust/random.h>
#include <thrust/device_vector.h>
#include <thrust/transform.h>
#include <thrust/iterator/counting_iterator.h>
#include <iostream>

#define pi_f  3.14159265358979f 

 struct prg
{
   float a, b;

    __host__ __device__
    prg(float _a=0.f, float _b=1.f) : a(_a), b(_b) {};

    __host__ __device__
        float operator()(const unsigned int n) const
        {
            thrust::default_random_engine rng;
            thrust::uniform_real_distribution<float> dist(a, b);
            rng.discard(n);
            return dist(rng);
        }
};


// want to integrate f = sin(x)
struct integrand_functor
{
    __host__ __device__
    float operator()(float x) const
    {
        return sin(x);
    }
};


int main(void)
{
    const int N = 20000000;
    // generate uniform r.v. from a = 0, b = pi
    const float a = 0.0f;
    const float b = pi_f;
    thrust::device_vector<float> numbers(N);
    thrust::counting_iterator<unsigned int> index_sequence_begin(0);
   
    thrust::transform(index_sequence_begin,
            index_sequence_begin + N,
            numbers.begin(),
            prg(a,b));

    // evaluate function values at each random numbers
   thrust::device_vector<float> eva(N);
   thrust::transform(numbers.begin(), numbers.end(),eva.begin(), 
               integrand_functor());
    
    float sum = thrust::reduce(eva.begin(), eva.end(), 0.f,
              thrust::plus<float>());
    /*for(int i = 0; i < N; i++)
    {
        std::cout << numbers[i] << std::endl;
	std::cout << eva[i] << std::endl;

    }
    std::cout << sum << std::endl;*/
    
    std::cout << "The integral of sin(x) from " << a << " to " <<b<< " is "<< sum*(b-a)/N << std::endl;
        return 0;
}
