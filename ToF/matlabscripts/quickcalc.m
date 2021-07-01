Twin = 0.1;
tstart = rxtshfcA(1);
tofAB = [];
timetof = [];
margin = 0;

while 1,
  tend = tstart + Twin;
  subindexesA = find(rxtshfcA > tstart & rxtshfcA < tend);
  subindexesB = find(txtshfcB > (tstart - margin) & txtshfcB < (tend + margin));

  if tstart > max(rxtshfcA),
    break;
  end;
  if length(subindexesA) > 0 & length(subindexesB) > 0,
    rxtshfcA_sub = rxtshfcA(subindexesA);
    txtshfcA_sub = txtshfcA(subindexesA);
    txtshfcB_sub = txtshfcB(subindexesB);
    rxtshfcB_sub = rxtshfcB(subindexesB);
  
    % calcolo skew A->B
    Ycolv = txtshfcA_sub;
    Xcolv = rxtshfcA_sub;
    Const = ones(size(Xcolv));
    Coeffs = [Xcolv Const]\Ycolv;
    mAB = Coeffs(1);
  
    rxtshfcA_sub = mAB * rxtshfcA_sub;
    txtshfcB_sub = mAB * txtshfcB_sub;
  
    for kk = 1:length(rxtshfcA_sub),
      % trova tempo t1 e t2
      rxBatA = rxtshfcA_sub(kk);
      txB = txtshfcA_sub(kk);
      % ora cerca il tempo di trasmissione di A successivo a rxBatA
      indtmp = find(txtshfcB_sub > rxBatA);
      if isempty(indtmp),
        continue;
      end;
      txA = txtshfcB_sub(indtmp(1));
      rxAatB = rxtshfcB_sub(indtmp(1));
  
      tof = ( (rxAatB - txB) - (txA - rxBatA) ) / 2;
      tofAB = [tofAB tof];
      timetof = [timetof rxBatA];
    end;
  end;

  tstart = tstart + Twin;
end;

lengthABs = ((tofAB) - tof8meter) * clight + dist0;
lengthAB = mean(lengthABs);

