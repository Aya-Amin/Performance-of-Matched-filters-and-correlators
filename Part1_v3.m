clear all
%1-
s1 = ones(1,10);
s2 = zeros(1,10);

%2-Generate signal
x = randi([0 1],1,1e6);                                        %Vector of rand values, of size 1*e6

%3-Represent each bit with proper waveform, m = 10
% x10 = repelem(x, 10);
waveForm = zeros(1,10e6);
for i = 0:length(x)-1 
    if x(i+1) == 1                                              %if the input bit is 1 representaion is rect of amp 1
        val = s1;    
    else         
        val = s2;                                               %else representation is zero
    end
    waveForm((10*i)+1:10*i+length(val)) = val;                          %filling the preallocated waveform
end
    
%4-Add noise to samples
ber = [];
corBer = [];
SNR = [0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30];
for snr = 0:2:30
    noisyWF = awgn(waveForm, snr, 'measured');
    xNoisy = awgn(x, snr, 'measured');
    
    %5-Apply convolution process in the receiver
        %Response of matched filter
    diff = s1 - s2;
    h = diff(end:-1:1);                                                    %reflection and shift with t=T
    
    received = zeros(1,length(x));
    convOP = zeros(1, (2*10-1)*length(x));
    
    for i = 0:length(x)-1
        noisyWF_10 = noisyWF((i*10)+1:(i+1)*10);                           %Extracting 10 samples
        c = conv(noisyWF_10,h);
        %Concatenating the conv results
        convOP( (length(h)+length(noisyWF_10)-1)*i+1:(length(h)+length(noisyWF_10)-1)*i+length(c) ) = c;  
        m = 10 + (length(h)+length(noisyWF_10)-1)*(i);                     %middle sample index
        received(i+1) = convOP(m);                            %concatenating the middle sample to the o/p   
    end
    
    %Calculating threshold
    TH = sum(received)/length(received);
    received_TH = zeros(1, 1e6);
    for j = 1:length(received)
        if(received(j) >= TH)
            received_TH(j) = 1;
        else
            received_TH(j) = 0;
        end 
    end
    
    [number, ratio] = biterr(x, received_TH, []);
    ber = [ber ratio]; 
     
        %Correlator
    xReceived = x.*xNoisy;
    TH = sum(xReceived)/length(xReceived);
    xReceived_TH = zeros(1, 1e6);
    for j = 1:length(xReceived)
        if(xReceived(j) >= TH)
            xReceived_TH(j) = 1;
        else
            xReceived_TH(j) = 0;
        end 
    end
    
    [number, ratio] = biterr(x, xReceived_TH, []);
    corBer = [corBer ratio];       
end

figure;
semilogy(SNR, ber);
title('Matched filter');

figure;
semilogy(SNR, corBer);
title('Correlator');

figure;
semilogy(SNR, ber,'r');
hold on;
semilogy(SNR, corBer,'g');
hold off;
legend('matched filter','correlator');
