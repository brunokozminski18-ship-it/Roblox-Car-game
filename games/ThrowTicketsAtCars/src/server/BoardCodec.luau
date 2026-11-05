--!strict
-- LihFolk Vault V2: monotonic big-number encodings. Ordered stores accept integers only.
-- Reserve eight decimal digits for the profile generation; encoded maximum is 1e15 (<2^53).
local Codec={Base=100000000}
function Codec.pack(name: string,value: number,generation: number): number
 assert(generation>=0 and generation<Codec.Base and generation%1==0,"Invalid board generation")
 local code=math.floor(value)
 if name=="TopMoney"and value>1e6 then code=1000000+math.floor(math.log10(value/1e6)*1e6)end
 return code*Codec.Base+generation
end
function Codec.unpack(name: string,packed: number): (number,number,boolean)
 local code=math.floor(packed/Codec.Base);local generation=packed%Codec.Base
 local approximate=name=="TopMoney"and code>1000000
 local value=if approximate then math.floor(1e6*10^((code-1000000)/1e6))else code
 return value,generation,approximate
end
return Codec
