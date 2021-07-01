
reference = zeros([256 4]);
for kk = 1:4,
  reference(:, kk) = csi_storeA_aoa{1}.core{kk}.nss{1}.data;
end;

figure(1); clf; hold on;

fase_rotations = [];
for jj = 2:length(csi_storeA_aoa),
  this = zeros([256 4]);
  for kk = 1:4,
    this(:, kk) = csi_storeA_aoa{jj}.core{kk}.nss{1}.data ./ reference(:, kk);
  end;

  fase_rotation = zeros([3 1]);
  colors = 'brg';
  for qq = 2:4,
    ratio = this(:, 1) ./ this(:, qq);
    plot(unwrap(angle(ratio)), colors(qq - 1));
    drawnow;
    d = diff(angle(ratio));
    fase_rotation(qq - 1) = mean([d(7:126); d(131:250)]);
  end;
  fase_rotations = [fase_rotations fase_rotation];
end;
