-- make the selected dwarf 20 years old, or the specified age with -age
-- by vjek
--@ module = true
--[====[

rejuvenate
==========
Sets the age of the selected dwarf to 20 years old by default. Useful if valuable citizens
are getting old.

Arguments:

- ``-all``: applies to all citizens
- ``-force``: also applies to units under 20 (or the age specified with -age) years old. Useful if there are too many babies around...
- ``-dry-run``: only list units that would be changed; don't actually change ages
- ``-age``: set to the specified age, rather than 20.

]====]

local utils = require('utils')

function rejuvenate(unit, force, dry_run, age)
    local current_year = df.global.cur_year
    if not age then
        age = 20
    end
    local new_birth_year = current_year - age
    local name = dfhack.df2console(dfhack.TranslateName(dfhack.units.getVisibleName(unit)))
    if unit.birth_year > new_birth_year and not force then
        print(name .. ' is under ' .. age .. ' years old. Use -force to force.')
        return
    end
    if dry_run then
        print('would change: ' .. name)
        return
    end
    unit.birth_year = new_birth_year
    if unit.old_year < new_birth_year + 160 then
        unit.old_year = new_birth_year + 160
    end
    if unit.profession == df.profession.BABY or unit.profession == df.profession.CHILD then
        unit.profession = df.profession.STANDARD
    end
    print(name .. ' is now ' .. age .. ' years old and will live to at least 160')
end

function main(args)
    local current_year, newbirthyear
    local units = {} --as:df.unit[]
    if args.all then
        for _, u in ipairs(df.global.world.units.all) do
            if dfhack.units.isCitizen(u) then
                table.insert(units, u)
            end
        end
    else
        table.insert(units, dfhack.gui.getSelectedUnit(true) or qerror("No unit under cursor! Aborting."))
    end
    for _, u in ipairs(units) do
        rejuvenate(u, args.force, args['dry-run'], args.age)
    end
end

if dfhack_flags.module then return end

main(utils.processArgs({...}, utils.invert({
    'all',
    'force',
    'dry-run',
    'age'
})))
