--[[
A very tiny linear algebra library. Used with nodal_analysis.lua.

Included functions:

    ["create_matrix"]: Creates an empty n x n matrix

    ["create_vector"] = Creates an empty vector of size n

    ["solve_system"] = Solves the system A * x = B. Inputs are A and B, where A is a matrix and B is a vector.
--]]

-- Helper function: Create an empty matrix of size n x n
local function create_matrix(n)
    local matrix = {}
    for i = 1, n do
        matrix[i] = {}
        for j = 1, n do
            matrix[i][j] = 0
        end
    end
    return matrix
end

-- Helper function: Create an empty vector of size n
local function create_vector(n)
    local vector = {}
    for i = 1, n do
        vector[i] = 0
    end
    return vector
end

-- Helper function: Solve a system of linear equations A * x = B
-- Using Gaussian elimination for solving linear equations.
local function solve_system(A, B)
    local n = #A

    -- Forward elimination
    for i = 1, n do
        -- Pivoting (swap rows to avoid division by zero)
        local max_row = i
        for k = i + 1, n do
            if math.abs(A[k][i]) > math.abs(A[max_row][i]) then
                max_row = k
            end
        end
        A[i], A[max_row] = A[max_row], A[i]
        B[i], B[max_row] = B[max_row], B[i]

        -- Eliminate lower rows
        for k = i + 1, n do
            local factor = A[k][i] / A[i][i]
            for j = i, n do
                A[k][j] = A[k][j] - factor * A[i][j]
            end
            B[k] = B[k] - factor * B[i]
        end
    end

    -- Back substitution
    local V = create_vector(n)
    for i = n, 1, -1 do
        local sum = 0
        for j = i + 1, n do
            sum = sum + A[i][j] * V[j]
        end
        V[i] = (B[i] - sum) / A[i][i]
    end

    return V
end

local iblib_linear_algebra = {
    ["create_matrix"] = create_matrix,
    ["create_vector"] = create_vector,
    ["solve_system"] = solve_system,
}

return iblib_linear_algebra
