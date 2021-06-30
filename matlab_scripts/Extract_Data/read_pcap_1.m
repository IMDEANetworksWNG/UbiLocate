function [cmplxall,outputArg2] = read_pcap_1(FILE,BW)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here
HOFFSET = 16;           % header offset
NFFT = BW*3.2;          % fft size
p = readpcap();
p.open(FILE);
n = min(length(p.all()), 20000000);
p.from_start();
csi_buff = complex(zeros(n,NFFT),0);
k = 1;

slice = uint32(0); % zeros([256 4]);
% powers = [];

prevfwcnt = -1;
processedcore = 1;
processedpacket = 0;

% reference = zeros([NFFT 4]);
cmplxall = zeros([0, NFFT 4]);
% delta = zeros([0, NFFT 4]);
% metadata = uint16(zeros([0,NFFT]));
% aux = [];
counter = 0;
% txtsdata = [];

while (k <= n)
    f = p.next();
    if isempty(f)
        disp('no more frames');
        break;
    end
    if f.header.orig_len-(HOFFSET-1)*4 < NFFT*4
        disp('skipped frame with incorrect size');
        processedmask = 0;
%         prevfwcnt = fwcnt;
        prevfwmask = -1;
        slice = uint32(0);
        continue;
    end
    
%     wirelesstype = uint16([65 0 144])';
%     % udp starts with broadcast address [ffff ffff ffff]
    udptype = uint16([65535 65535 65535])';
%     
%     %try
        LEN = length(f.payload);
        LEN = 2 * floor(LEN / 2);
        data = typecast(f.payload(1:LEN), 'uint16');
%     %catch
%     %    break;
%     %end
%     
%     if isequal(data(1:3), wirelesstype),
%         % check this is the right packet 
%         % 0x0090:  8802 0000 ffff ffff ffff 0012 3456 789b  ............4Vx.
% %         expectedheader = uint16([0 648 0 65535 65535 65535 4608 22068 39800])';
%         expectedheader = uint16([0 128 0 65535 65535 65535 44004 31625 35484]).';
% 
%         if length(data) >= 80 & isequal(data(72:80), expectedheader),
%             % extract ts and sequence number of this frame, (we should match it with the
%             % sequence number in the next packet with the csi but it's not important right now)
%             % just remember the sequence number and the timestamp so that we have the transmission
%             % time stamp for that sequence number
%             % 0x00a0:  79e5 7c7f 5016 6016 0000 aaaa 0300 0000  y.|.P.`.........
%             sn = data(83);
%             txts = typecast(flipud(data(81:82)), 'uint32');
%             txtsdata = [txtsdata; [uint32(sn) txts]];
%         end;
%         continue;
%     end;
% 
    data(1:3);
    data(24);
    if ~ isequal(data(1:3), udptype),
        continue;
    end;
    

    % extract number of packet processed by the firmware and rxcore for this packet
    fwcnt = bitand(f.payload(15), 65535 * 65536) / 65536;
    rxcore = bitand(f.payload(14), 255 * 65536) / 65536 / 4 + 1;
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
      if processedcore < 4,
        disp(sprintf('missing data for packet %d\n', realprevfwcnt));
      end;
      processedcore = 0;
      prevfwcnt = fwcnt;
      slice = uint32(0);
    end;

    processedcore = processedcore + 1;

    % this should not happen
    if processedcore > 4,
      disp 'More than 4 rxcore for this packet, terminating...';
      processedcore = rxcore;
%       break;
    end;

    if size(slice, 1) == 1,
      slice = uint32(zeros([length(f.payload) 4]));
    end;

    slice(:, rxcore) = f.payload;

    % if we have 4 data for this packet process everything
    if processedcore == 4

      % extract CSI and plot phase differences
      % 1) extraction
      counter = counter + 1;

      for jj = 1:4,
        payload = slice(:, jj);
        H = payload(HOFFSET:HOFFSET+NFFT-1);
        Hout = unpack_float(int32(1), int32(NFFT), H);
        Hout = reshape(Hout,2,[]).';
        cmplx = double(Hout(1:NFFT,1))+1j*double(Hout(1:NFFT,2));
        cmplx = cmplx([((NFFT/2)+1):NFFT 1:(NFFT/2)]);

%         if processedpacket == 0,
%           disp(sprintf('Assigned reference for core %d\n', jj));
% 
%                load("reference")
% 
%         end;
        cmplxall(counter,:, jj) = cmplx; %./ reference(:, jj);


        size(cmplxall);
%         cmplxall = cmplx;
      end;

      % 2) plot
%       for jj = 1:3,
%         subplot(3, 1, jj);
%         hold on;
%         
%         a = cmplxall(counter,:, 1);
%         b = cmplxall(counter,:, jj + 1);
%         delta = angle(a ./ b);
%         X0 = [127 131];
%         X1 = X0(1) + 1:X0(2) - 1;
%         Y0 = delta(X0);
%         Y1 = interp1(X0, Y0, X1);
%         delta(X1) = Y1;
%         delta = unwrap(delta);
%         delta(counter,:, jj+1) = delta - delta(129);
%         tones = -128:127;
%         plot(tones(8:249), delta(counter,8:249, jj+1));
%         ylim([-1 1]);
%       end;

      % extract metadata
      metadata_aux = [];
      for jj = 1:4,
        payload = slice(:, jj);
        data = typecast(payload(HOFFSET+NFFT:end), 'uint16');
        metadata_aux = [metadata_aux; data];
      end;
%       metadata(counter,:) = metadata_aux;

      % powers
%       powers = zeros([1 4]);
%       tmp = typecast(metadata_aux(4), 'uint8');
%       powers(1) = tmp(2);
%       tmp = typecast(metadata_aux(5), 'uint8');
%       powers(2:3) = tmp;
%       tmp = typecast(metadata_aux(6), 'uint8');
%       powers(4) = tmp(1);
%           
      processedpacket = processedpacket + 1;

%       processedcore = 1;
%       power_all(processedpacket,:) = powers;
      % do something with metadata
      % ADD YOUR CODE HERE

    end;

    k = k + 1;
end

end

