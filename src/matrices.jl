for (elty, relty, ext) in ((:Integer, :Integer, :i),
                           (:Float32, :Float32, :s),
                           (:Float64, :Float64, :d),
                           (:Complex64, :Float32, :c),
                           (:Complex128, :Float64, :z))

    for (mat, sym) in ((:Matrix, "_"),
                       (:DistMatrix, "Dist_"),
                       (:DistMultiVec, "DistMultiVec_"))
        @eval begin
            # Bernoulli
            function bernoulli!(A::$mat{$elty}, m::Integer, n::Integer)
                err = ccall(($(string("ElBernoulli", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt),
                    A.obj, m, n)
                err == 0 || throw(ElError(err))
                return A
            end

            # Gaussian
            function gaussian!(A::$mat{$elty}, m::Integer, n::Integer,
                               mean::Number = 0, stddev::Number = 1)
                err = ccall(($(string("ElGaussian", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt, $elty, $relty),
                    A.obj, m, n, mean, stddev)
                err == 0 || throw(ElError(err))
                return A
            end

            # Ones
            function ones!(A::$mat{$elty}, m::Integer, n::Integer)
                err = ccall(($(string("ElOnes", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt),
                    A.obj, m, n)
                err == 0 || throw(ElError(err))
                return A
            end

            # Uniform
            function uniform!(A::$mat{$elty}, m::Integer, n::Integer,
                              center::Number = 0, radius::Number = 1)
                err = ccall(($(string("ElUniform", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt, $elty, $relty),
                    A.obj, m, n, center, radius)
                err == 0 || throw(ElError(err))
                return A
            end

            # Zeros
            function zeros!(A::$mat{$elty}, m::Integer, n::Integer)
                err = ccall(($(string("ElZeros", sym, ext)), libEl), Cuint,
                    (Ptr{Void}, ElInt, ElInt),
                    A.obj, m, n)
                err == 0 || throw(ElError(err))
                return A
            end
        end

        if elty == :Complex64 || elty == :Complex128
            # Uniform
            @eval begin
                function foxLi!(A::$mat{$elty}, n::Integer, omega::Real)
                    err = ccall(($(string("ElFoxLi", sym, ext)), libEl), Cuint,
                        (Ptr{Void}, ElInt, $relty),
                        A.obj, n, omega)
                    err == 0 || throw(ElError(err))
                    return A
                end
            end
        end
    end
end
