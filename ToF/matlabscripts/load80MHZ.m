% function [tshfc tssfc csi_store sncsis txtsdata packets correz] = load20MHZ(FILE, BW);
function [rxtshfc rxtssfc csi_store sncsis txtshfc packets correz] = load20MHZ(FILE, BW);
 
%% csireader.m
%
% read and plot CSI from UDPs created using the nexmon CSI extractor (nexmon.org/csi)
% modify the configuration section to your needs
% make sure you run >mex unpack_float.c before reading values from bcm4358 or bcm4366c0 for the first time
%
%

%% configuration
CHIP = '4366c0';          % wifi chip (possible values 4339, 4358, 43455c0, 4366c0)
% BW = 80;                % bandwidth
% FILE = './trace10_80M.pcap';

HOFFSET = 16;           % header offset
NFFT = BW*3.2;          % fft size
p = readpcap();
p.open(FILE);
n = length(p.all());
p.from_start();
k = 0;

prevfwcnt = -1;
nss_config = 1;
rxcore_config = 1;
mask_toprocess = nss_config * rxcore_config;
slice = uint32(0);

processedmask = mask_toprocess;
processedpacket = 0;
chars='|/-\';
output = '';
fprintf(1, '.');

prevfwmask = -1;

csi_store = {};
packets = 1;
tshfc = [];
tssfc = [];
metadatas = [];
sncsis = [];

txtsdata = [];

while (k < n)
    k = k + 1;
    for jj = 1:length(output) + 1, fprintf(1, '\b'); end;
    charjj = mod(k, length(chars)) + 1;
    output = sprintf(' %.0f/100', k / n * 100);
    fprintf(1, '%c%s', chars(charjj), output);
    f = p.next();
    if isempty(f)
        disp('no more frames');
        return;
    end

    % we can have wireless packet or the udp stuff with csi
    % wireless packet starts with prism header, assume is always [4100 0000 9000]
    wirelesstype = uint16([65 0 144])';
    % udp starts with broadcast address [ffff ffff ffff]
    udptype = uint16([65535 65535 65535])';
    
    data = typecast(f.payload(1:end), 'uint16');

    if isequal(data(1:3), wirelesstype),
        % check this is the right packet 
	% we use mac addr 2 as filter: last two bytes as index of station
        % 0x0090:  8802 0000 ffff ffff ffff 0012 3456 789b  ............4Vx.
        expectedheader = uint16([0 648 0 65535 65535 65535 4608 22068 ])';
        if length(data) >= 80 & isequal(data(72:79), expectedheader),
            % extract ts and sequence number of this frame, (we should match it with the
            % sequence number in the next packet with the csi but it's not important right now)
            % just remember the sequence number and the timestamp so that we have the transmission
            % time stamp for that sequence number
            % 0x00a0:  79e5 7c7f 5016 6016 0000 aaaa 0300 0000  y.|.P.`.........
            sn = data(83);
            txts = typecast(flipud(data(81:82)), 'uint32');
            txtsdata = [txtsdata; [uint32(sn) txts]];
        end;
        continue;
    end;

    % from this point we are processing the udp containing the csidata
    if ~ isequal(data(1:3), udptype),
        continue;
    end;

    % for quick reference:
    %							byte offset in packet
    % payload(1)  first  w32: data(1)  and data(2)	0x0000
    % payload(2)  second w32: data(3)  and data(4)	0x0004
    % ...
    % payload(11) ..........: data(21) and data(22)	0x0028
    % payload(12) ..........: data(23) and data(24)	0x002c
    % payload(13) ..........: data(25) and data(26)	0x0030
    % payload(14) ..........: data(27) and data(28)	0x0034
    % payload(15) ..........: data(29) and data(30)	0x0038
    %
    % packet structure:
    % 0x0022: udp port
    % 0x0024: udp port
    % 0x0026: udp len
    % 0x0028: udp checksum
    % 0x002a: 11111111 (magic)
    % 0x002c: mac address of transmitter
    % 0x0034: seq counter of wireless frame
    % 0x0036: csi configuration
    % 0x0038: chanspec
    % 0x003a: firmware counter (increase with frame, not CSI chunks)
    %
    % to recap:
    % payload(14) contains 0x0034 and 0x0036
    % payload(15) contains 0x0038 and 0x003a

    if f.header.orig_len-(HOFFSET-1)*4 < NFFT*4
        disp('skipped frame with incorrect size');
        return;
    end

    % extract sequence number... if there are multiple csi for the same packet, it will be the same
    % and we will put into sncsis only once
    sncsi = data(27);

    % extract number of packet processed by the firmware and rxcore for this packet
    SN = typecast(f.payload(14), 'uint16');
    %disp(sprintf('%d\n', SN));
    %disp(sprintf('%d\n', SN));
    fwcnt = bitand(f.payload(15), 65535 * 65536) / 65536;
    fwmask = bitand(f.payload(14), 255 * 65536) / 65536;
    rxcore = double(bitand(fwmask, 12) / 4 + 1);
    nss = double(bitand(fwmask, 3) + 1);
    % disp(sprintf('%d %d %d %d', [fwcnt fwmask rxcore nss]));

    rxcore = double(rxcore);

    % if fwcnt wrapped around, then this is like when we have a new packet
    realprevfwcnt = prevfwcnt;
    if fwcnt < prevfwcnt,
      disp 'fwcnt wrapped around...';
      prevfwcnt = fwcnt - 1;
    end;

    % if this data is for a new packet, reset number of rxcore for this packet
    % report if for the previous packet we did not received all rxcore data
    if fwcnt > prevfwcnt,
      if processedmask < mask_toprocess,
        disp(sprintf('\nmissing data for packet %d\n', realprevfwcnt));
        for jj = 1:length(output), fwrite(1, 10); end;
        % drawnow('update');
      end;
      processedmask = 0;
      prevfwcnt = fwcnt;
      prevfwmask = -1;
      slice = uint32(0);
    end;

    processedmask = processedmask + 1;

    % disp(sprintf('%d %d %d %d %d', [fwmask, processedmask, mask_toprocess, prevfwcnt, fwcnt]));

    % this should not happen
    if processedmask > mask_toprocess,
      disp(sprintf('More than %d masks for this packet, terminating...', mask_toprocess));
      break;
    end;

    if size(slice, 1) == 1,
      slice = uint32(zeros([length(f.payload) 4]));
    end;

    slice(:, fwmask + 1) = f.payload;

    if fwmask < prevfwmask,
      disp(sprintf('\nfwmask goes backward, skipping CSI %d\n', fwcnt));
      for jj = 1:length(output), fwrite(1, 10); end;
      % drawnow('update');
      processedmask = 0;
      prevfwcnt = fwcnt;
      prevfwmask = -1;
      slice = uint32(0);
    end;

    prevfwmask = fwmask;

    % if we have enough data for this packet process everything
    Np = 0;
    if BW == 20,
      Np = 64;
    elseif BW == 80,
      Np = 256;
    else
      disp 'BAND??';
      keyboard
    end;
    if processedmask == mask_toprocess,
      cmplxall = zeros([Np mask_toprocess]);
      cmplxall_raw = zeros([Np mask_toprocess]);
      metadata = [];

      % extract CSI
      % 1) extraction
      for jj = 1:mask_toprocess,
        payload = slice(:, jj);
        H = payload(HOFFSET:HOFFSET+NFFT-1);
        Hout = unpack_float(int32(1), int32(NFFT), H);
        Hout = reshape(Hout,2,[]).';
        cmplx = double(Hout(1:NFFT,1))+1j*double(Hout(1:NFFT,2));
        if BW == 20,
          cmplx = cmplx([33:64 1:32]);
        elseif BW == 80,
          cmplx = cmplx([129:256 1:128]);
        end;

        cmplxall_raw(:, jj) = cmplx;
	% normalisation
        % cmplx = cmplx ./ reference(:, jj);
        cmplxall(:, jj) = cmplx;

        % metadata
        data = typecast(payload(HOFFSET+NFFT:end), 'uint16');
        metadata = [metadata data'];
      end;

      csi_store{packets} = cmplxall;
      sncsis = [sncsis; sncsi];
      metadatas = [metadatas; metadata];
      tslo = uint32(metadata(26));
      tshi = uint32(metadata(27));
      ts2lo = uint32(metadata(18));
      ts2hi = uint32(metadata(19));
      tshfc = [tshfc; tshi * 65536 + tslo];
      tssfc = [tssfc; ts2hi * 65536 + ts2lo];
      packets = packets + 1;

      if 0,
        figure(1); clf;
        for jj = 1:mask_toprocess,
          subplot(nss_config, rxcore_config, jj);
          plot(abs(cmplxall_raw(:, jj)));
        end;
        drawnow;
      end;

    end;

end

packets = packets - 1;

% now we have two datasets
% 1) tshfc, tssfc, csi_store, sncsis
% 2) txtsdata
% we should keep only packets for which we have both tx and rx timestamps


[cmn, ia, ib] = intersect(uint32(sncsis), txtsdata(:, 1));
rxtshfc = tshfc(ia);
rxtssfc = tssfc(ia);
csi_store = csi_store(ia);
sncsis = sncsis(ia);
txtshfc = txtsdata(ib, 2);
packets  = length(rxtshfc);

load(sprintf('reference80true.mat', BW)); 
correz = [];
for kk = 1:packets,
  csis = transpose(csi_store{kk});
  csi = csis(1, :);

  diffs = diff(unwrap(angle(csi ./ reference)));

  if BW == 20,
    left = diffs(7:32);
    rigt = diffs(34:59);
  elseif BW == 80,
    left = diffs(7:127);
    rigt = diffs(131:251);
  end;
  correz = [correz; median(left(2:end - 1)) median(rigt(2:end - 1))];
end;
correz = correz / 2 / pi / 312.5e3;

FREQ = 2^26 / 348436 * 1e6;
rxtshfc = double(rxtshfc) / FREQ + correz(:, 1);
txtshfc = double(txtshfc) / FREQ;
rxtssfc = double(rxtssfc);

% txtimes = double(txtsdata(:, 2)) / FREQ;
% rxtimes = double(tshfc) / FREQ;
% rxtimes = rxtimes - correz(:, 1);
