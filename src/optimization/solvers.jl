# Linear Programming
# ==================
const ElLPApproach = Cuint

const LP_ADMM = ElLPApproach(0)
const LP_MEHROTRA = ElLPApproach(1)

const ElKKTSystem = Cuint

const FULL_KKT = ElKKTSystem(0)
const AUGMENTED_KKT = ElKKTSystem(1)
const NORMAL_KKT = ElKKTSystem(2)

struct MehrotraCtrl{T<:ElFloatType}
    primalInit::ElBool
    dualInit::ElBool
    minTol::T
    targetTol::T
    maxIts::ElInt
    maxStepRatio::T
    system::ElKKTSystem
    mehrotra::ElBool
    forceSameStep::ElBool
    solveCtrl::RegSolveCtrl{T}
    resolveReg::ElBool
    outerEquil::ElBool
    basisSize::ElInt
    print::ElBool
    time::ElBool
    wSafeMaxNorm::T
    wMaxLimit::T
    ruizEquilTol::T
    ruizMaxIter::ElInt
    diagEquilTol::T
    checkResiduals::ElBool
end
function MehrotraCtrl(::Type{T};
    primalInit::Bool = false,
    dualInit::Bool = false,
    minTol = eps(T)^0.3,
    targetTol = eps(T)^0.5,
    maxIts = 1000,
    maxStepRatio = 0.99,
    system = FULL_KKT,
    mehrotra = true,
    forceSameStep = true,
    solveCtrl = RegSolveCtrl(T),
    resolveReg = true,
    outerEquil::Bool = true,
    basisSize = 6,
    print = false,
    time = false,
    wSafeMaxNorm = eps(T)^(-0.15),
    wMaxLimit = eps(T)^(-0.4),
    ruizEquilTol = eps(T)^(-0.25),
    ruizMaxIter = 3,
    diagEquilTol = eps(T)^(-0.15),
    checkResiduals = false) where {T<:ElFloatType}

    MehrotraCtrl{T}(ElBool(primalInit),
                    ElBool(dualInit),
                    T(minTol),
                    T(targetTol),
                    ElInt(maxIts),
                    T(maxStepRatio),
                    ElKKTSystem(system),
                    ElBool(mehrotra),
                    ElBool(forceSameStep),
                    solveCtrl,
                    ElBool(resolveReg),
                    ElBool(outerEquil),
                    ElInt(basisSize),
                    ElBool(print),
                    ElBool(time),
                    T(wSafeMaxNorm),
                    T(wMaxLimit),
                    T(ruizEquilTol),
                    ElInt(ruizMaxIter),
                    T(diagEquilTol),
                    ElBool(checkResiduals))
end

struct LPAffineCtrl{T<:ElFloatType}
    approach::Cuint
    mehrotraCtrl::MehrotraCtrl{T}
end

function LPAffineCtrl(::Type{T};
    approach::Cuint = LP_MEHROTRA,
    mehrotraCtrl::MehrotraCtrl = MehrotraCtrl(T)) where {T<:ElFloatType}

    LPAffineCtrl{T}(approach, mehrotraCtrl)
end

for (elty, ext) in ((:Float32, :s),
                    (:Float64, :d))
    @eval begin
        function LPAffine(
            A::DistSparseMatrix{$elty},
            G::DistSparseMatrix{$elty},
            b::DistMultiVec{$elty},
            c::DistMultiVec{$elty},
            h::DistMultiVec{$elty},
            x::DistMultiVec{$elty},
            y::DistMultiVec{$elty},
            z::DistMultiVec{$elty},
            s::DistMultiVec{$elty},
            ctrl::LPAffineCtrl=SOCPAffineCtrl($elty))
            ElError(ccall(($(string("ElLPAffine_", ext)), libEl), Cuint,
                (Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},
                 Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},
                 LPAffineCtrl{$elty}),
                A.obj, G.obj, b.obj, c.obj, h.obj,
                x.obj, y.obj, z.obj, s.obj, ctrl))
            return nothing
        end
    end
end

# Second-Order Cone Programming
# =============================
const SOCP_ADMM = Cuint(0)
const SOCP_IPF = Cuint(1)
const SOCP_IPF_SELFDUAL = Cuint(2)
const SOCP_MEHROTRA = Cuint(3)
const SOCP_MEHROTRA_SELFDUAL = Cuint(4)

struct SOCPAffineCtrl{T<:ElFloatType}
    approach::Cuint
    mehrotraCtrl::MehrotraCtrl{T}
end
function SOCPAffineCtrl(::Type{T};
                      approach::Cuint = SOCP_MEHROTRA,
                      mehrotraCtrl::MehrotraCtrl = MehrotraCtrl(T)) where {T<:ElFloatType}

    SOCPAffineCtrl{T}(approach, mehrotraCtrl)
end

for (elty, ext) in ((:Float32, :s),
                    (:Float64, :d))
    @eval begin
        function SOCPAffine(
            A::DistSparseMatrix{$elty},
            G::DistSparseMatrix{$elty},
            b::DistMultiVec{$elty},
            c::DistMultiVec{$elty},
            h::DistMultiVec{$elty},
            orders::DistMultiVec{ElInt},
            firstInds::DistMultiVec{ElInt},
            labels::DistMultiVec{ElInt},
            x::DistMultiVec{$elty},
            y::DistMultiVec{$elty},
            z::DistMultiVec{$elty},
            s::DistMultiVec{$elty},
            ctrl::SOCPAffineCtrl=SOCPAffineCtrl($elty))

            ElError(ccall(($(string("ElSOCPAffine_", ext)), libEl), Cuint,
                (Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},
                 Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},
                 Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},Ptr{Cvoid},
                 SOCPAffineCtrl{$elty}),
                A.obj, G.obj, b.obj, c.obj, h.obj,
                orders.obj, firstInds.obj, labels.obj,
                x.obj, y.obj, z.obj, s.obj, ctrl))
            return nothing
        end
    end
end
