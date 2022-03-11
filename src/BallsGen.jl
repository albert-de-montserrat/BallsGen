module BallsGen

export generate_inclusions

# sphere volume
vol(r) = 4/3*π*r^3

# random inclusoin center
new_center(lx, ly, lz) = (rand()*lx, rand()*ly, rand()*lz)

# 3D euclidean distance
distance(p1, p2) = sqrt((p1[1]-p2[1])^2 + (p1[2]-p2[2])^2 + (p1[3]-p2[3])^2)

# check if the new inclusion collides with any pre-existent inclusion
function sphere_collision(coords, new_coord, r; buffer = 0.2)
    for c in coords
        if distance(c, new_coord) ≤ 2*r*(1 + buffer)
            return true
        end
    end

    return false
end

function wall_collision(new_coord, r, lx, ly, lz; buffer = 0.2)
    x, y, z = new_coord
    buffer += 1
    if (x ≤ r*buffer) || (x ≥ (lx - r*buffer))
        return true

    elseif (y ≤ r*buffer) || (y ≥ (ly - r*buffer))
        return true
    
    elseif (z ≤ r*buffer) || (z ≥ (lz - r*buffer))
        return true
    end

    return false
end

function generate_inclusions(lx, ly, lz, ϕ, r;  buffer_ball = 0.2, buffer_wall = 0.2)
    # first sphere coordinate
    coords = [new_center(lx, ly, lz)]

    tot_vol = vol(r)
    vol_fraction = tot_vol/(lx*ly*lz)

    iter = 0
    while vol_fraction ≤ ϕ
        iter += 1
        # temptative coordinate
        new_coord = new_center(lx, ly, lz) 
        collision1 = sphere_collision(coords, new_coord, r; buffer=buffer_ball)
        collision2 = wall_collision(new_coord, r, lx, ly, lz; buffer=buffer_wall)
        if !collision1 && !collision2
            push!(coords, new_coord)
            tot_vol += vol(r)
            vol_fraction = tot_vol/(lx*ly*lz)
            iter = 0
        end
        if iter > 500
            println("Forcing exit. Generator stalling")
            break
        end
    end

    println("Done with $(length(coords)) inclusions and $(vol_fraction*100) % volume fraction.")

    return coords, vol_fraction
end

end # module
