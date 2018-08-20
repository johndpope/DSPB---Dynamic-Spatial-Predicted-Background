function A=RemoveLowCC(B,k)

for i=1:size(B,3) %frames    
   A(:,:,i)=bwareaopen(B(:,:,i),k); 
end

end