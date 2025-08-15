function [Pxx, Pxxc, f] = psd(varargin)
% PSD has been deprecated, use PERIODOGRAM or PWELCH instead.
error(message('signal:deprecated:deprecatedPSD'));