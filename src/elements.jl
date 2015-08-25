# This file is a part of JuliaFEM.
# License is MIT: see https://github.com/JuliaFEM/JuliaFEM.jl/blob/master/LICENSE.md

abstract Element

"""
Get jacobian of element evaluated at point xi
"""
function get_jacobian(el::Element, xi)
    dbasisdxi(xi) = get_dbasisdxi(el, xi)
    X = get_coordinates(el)
    J = interpolate(X, dbasisdxi, xi)'
    return J
end

"""
Evaluate partial derivatives of basis function w.r.t
material description X, i.e. dbasis/dX
"""
function get_dbasisdX(el::Element, xi)
    dbasisdxi = get_dbasisdxi(el, xi)
    J = get_jacobian(el, xi)
    dbasisdxi*inv(J)
end

"""
Return coordinates of element in array of size dim x nnodes
"""
function get_coordinates(el::Element)
    el.coordinates
end

"""
Set coordinates for element
"""
function set_coordinates(el::Element, coordinates)
    el.coordinates = coordinates
end

"""
Get element id
"""
function get_element_id(el::Element)
    el.id
end



### Lagrange family ###

abstract CG <: Element # Lagrange element family

"""
Create new Lagrange element

FIXME: this is not working

LoadError: error compiling anonymous: type definition not allowed inside a local scope

It's the for loop which is causing problems. See
https://github.com/JuliaLang/julia/issues/10555

"""
function create_lagrange_element(element_name, X, P, dP)

    @eval begin

        nnodes, dim = size(X)
        A = zeros(nnodes, nnodes)
        for i=1:nnodes
            A[i,:] = P(X[i,:])
        end
        invA = inv(A)'

        type $element_name
            element_id :: Int
            node_ids :: Array{Int, 1}
            coordinates :: Array{Float64, 2}
            fields :: Dict{ASCIIString, Any}
        end

        function $element_name(element_id, node_ids)
            coordinates = zeros(dim, nnodes)
            fields = Dict{ASCIIString, Any}()
            $element_name(element_id, node_ids, coordinates, fields)
        end

        function $element_name(element_id, node_ids, coordinates)
            fields = Dict{ASCIIString, Any}()
            $element_name(element_id, node_ids, coordinates, fields)
        end

        function get_basis(el::$element_name, xi)
            invA*P(xi)
        end

        function get_dbasisdxi(el::$element_name, xi)
            invA*dP(xi)
        end

        $element_name

    end

end

# 0d Lagrange elements

"""
1 node point element
"""
type Point1 <: CG
    element_id :: Int
    node_ids :: Array{Int, 1}
    coordinates :: Array{Float64, 2}
    fields :: Dict{ASCIIString, Any}
end

# 1d Lagrange elements

"""
2 node linear line element
"""
type Seg2 <: CG
    element_id :: Int
    node_ids :: Array{Int, 1}
    coordinates :: Array{Float64, 2}
    fields :: Dict{ASCIIString, Any}
end

# X = [-1.0 1.0]'
# P = (xi) -> [1.0 xi[1]]'
# dP = (xi) -> [0.0 1.0]'
# create_lagrange_element(:Seg2, X, P, dP)

"""
3 node quadratic line element
"""
type Seg2 <: CG
    element_id :: Int
    node_ids :: Array{Int, 1}
    coordinates :: Array{Float64, 2}
    fields :: Dict{ASCIIString, Any}
end
#X = [-1.0 1.0 0.0]'
#P = (xi) -> [1.0 xi[1] xi[1]^2]'
#dP = (xi) -> [0.0 1.0 2*xi[1]]'
#create_lagrange_element(:Seg3, X, P, dP)

# 2d Lagrange elements

"""
4 node bilinear quadrangle element
"""
type Quad4 <: CG
    element_id :: Int
    node_ids :: Array{Int, 1}
    coordinates :: Array{Float64, 2}
    fields :: Dict{ASCIIString, Any}
end
function get_basis(el::Quad4, xi)
    [(1-xi[1])*(1-xi[2])/4
     (1+xi[1])*(1-xi[2])/4
     (1+xi[1])*(1+xi[2])/4
     (1-xi[1])*(1+xi[2])/4]
end
function get_dbasisdxi(el::Quad4, xi)
    [-(1-xi[2])/4.0    -(1-xi[1])/4.0
      (1-xi[2])/4.0    -(1+xi[1])/4.0
      (1+xi[2])/4.0     (1+xi[1])/4.0
     -(1+xi[2])/4.0     (1-xi[1])/4.0]
end
#X = [
#    -1.0 -1.0
#     1.0 -1.0
#     1.0  1.0
#    -1.0  1.0]
#P = (xi) -> [
#    1.0
#    xi[1]
#    xi[2]
#    xi[1]*xi[2]]
#dP = (xi) -> [
#      0.0   0.0
#      1.0   0.0
#      0.0   1.0
#    xi[2] xi[1]]
#create_lagrange_element(:Quad4, X, P, dP)

# 3d Lagrange elements

"""
10 node quadratic tethahedron
"""
type Tet10 <: CG
    element_id :: Int
    node_ids :: Array{Int, 1}
    coordinates :: Array{Float64, 2}
    fields :: Dict{ASCIIString, Any}
end
# X = [
#    0.0 0.0 0.0
#    1.0 0.0 0.0
#    0.0 1.0 0.0
#    0.0 0.0 1.0
#    0.5 0.0 0.0
#    0.5 0.5 0.0
#    0.0 0.5 0.0
#    0.0 0.0 0.5
#    0.5 0.0 0.5
#    0.0 0.5 0.5]
#    P(xi) = [
#        1
#        xi[1]
#        xi[2]
#        xi[3]
#        xi[1]^2
#        xi[2]^2
#        xi[3]^2
#        xi[1]*xi[2]
#        xi[2]*xi[3]
#        xi[3]*xi[1]]
#    dP(xi) = [
#        0 0 0
#        1 0 0
#        0 1 0
#        0 0 1
#        2*xi[1] 0 0
#        0       2*xi[2] 0
#        0       0       2*xi[3]
#        xi[2]   xi[1]   0
#        0       xi[3]   xi[2]
#        xi[3]   0       xi[1]
#    ]
#create_lagrange_element(:Tet10, X, P, dP)