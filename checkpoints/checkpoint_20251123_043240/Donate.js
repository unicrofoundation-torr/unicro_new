import React, { useEffect, useState } from 'react';
import PageBanner from '../components/PageBanner';
import { publicAPI } from '../services/api';

function loadRazorpayScript() {
  return new Promise((resolve, reject) => {
    if (window?.Razorpay) return resolve(window.Razorpay);
    const s = document.createElement('script');
    s.src = 'https://checkout.razorpay.com/v1/checkout.js';
    s.async = true;
    s.onload = () => resolve(window.Razorpay);
    s.onerror = reject;
    document.body.appendChild(s);
  });
}

const Donate = () => {
  const [cycle, setCycle] = useState(null); // null, weekly, monthly, yearly
  const [amount, setAmount] = useState('100');
  const [customAmount, setCustomAmount] = useState('');
  const [donor, setDonor] = useState({
    name: '',
    email: '',
    phone: '',
    address: ''
  });
  const [submitting, setSubmitting] = useState(false);
  const [submitted, setSubmitted] = useState(false);
  const [errors, setErrors] = useState({
    email: '',
    phone: ''
  });
  const [validatingEmail, setValidatingEmail] = useState(false);

  const presetAmounts = ['10', '50', '100', '500', '1000'];

  // Cycle-based amounts
  const cycleAmounts = {
    weekly: 7,
    monthly: 31,
    yearly: 365
  };

  // Get the active amount - prioritize custom amount, then cycle amount, then preset amount
  // Default to weekly amount if no cycle is selected and no custom amount
  const defaultCycle = 'weekly';
  const cycleAmount = cycle ? (cycleAmounts[cycle] || 0) : (cycleAmounts[defaultCycle] || 0);
  const activeAmount = customAmount !== '' ? customAmount : (cycleAmount || amount);

  // Validate phone number (Indian format)
  const validatePhone = (phone) => {
    if (!phone) return ''; // Phone is optional
    // Remove spaces and dashes
    const cleaned = phone.replace(/[\s-]/g, '');
    // Check for Indian phone format: +91XXXXXXXXXX or 0XXXXXXXXXX or XXXXXXXXXX (10 digits)
    const phoneRegex = /^(\+91|0)?[6-9]\d{9}$/;
    if (!phoneRegex.test(cleaned)) {
      return 'Please enter a valid Indian phone number (e.g., +91-9876543210 or 9876543210)';
    }
    return '';
  };

  // Validate email format
  const validateEmailFormat = (email) => {
    if (!email) return 'Email is required';
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return 'Please enter a valid email address';
    }
    return '';
  };

  // Check if email exists
  const checkEmailExists = async (email) => {
    try {
      setValidatingEmail(true);
      const response = await publicAPI.checkEmailExists(email);
      if (response.data.exists) {
        return 'This email is already registered. Please use a different email.';
      }
      return '';
    } catch (error) {
      console.error('Email check error:', error);
      // If check fails, don't block submission but log the error
      return '';
    } finally {
      setValidatingEmail(false);
    }
  };

  const handleDonorChange = async (e) => {
    const { name, value } = e.target;
    setDonor((prev) => ({ ...prev, [name]: value }));
    
    // Clear error when user starts typing
    if (errors[name]) {
      setErrors((prev) => ({ ...prev, [name]: '' }));
    }
    
    // Validate phone number
    if (name === 'phone') {
      const phoneError = validatePhone(value);
      setErrors((prev) => ({ ...prev, phone: phoneError }));
    }
    
    // Validate email format
    if (name === 'email') {
      const emailFormatError = validateEmailFormat(value);
      if (emailFormatError) {
        setErrors((prev) => ({ ...prev, email: emailFormatError }));
      } else if (value) {
        // Check if email exists (debounce this in production)
        const emailExistsError = await checkEmailExists(value);
        setErrors((prev) => ({ ...prev, email: emailExistsError }));
      }
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    // Validate all fields
    const emailFormatError = validateEmailFormat(donor.email);
    const phoneError = validatePhone(donor.phone);
    
    let emailExistsError = '';
    if (!emailFormatError && donor.email) {
      emailExistsError = await checkEmailExists(donor.email);
    }
    
    setErrors({
      email: emailFormatError || emailExistsError,
      phone: phoneError
    });
    
    // Check if there are any errors
    if (emailFormatError || emailExistsError || phoneError) {
      return;
    }
    
    if (!activeAmount || Number(activeAmount) <= 0) return;
    if (!donor.name || !donor.email) return;
    
    // If custom amount is entered, cycle should be null
    const selectedCycle = customAmount !== '' ? null : (cycle || defaultCycle);
    
    // If no cycle is selected and no custom amount, use default
    if (!selectedCycle && !customAmount) {
      alert('Please select a donation cycle or enter a custom amount');
      return;
    }
    
    setSubmitting(true);
    try {
      // 1) Create Razorpay subscription on server
      const { data } = await publicAPI.createRazorpaySubscription({
        amount: Number(activeAmount),
        name: donor.name,
        email: donor.email,
        phone: donor.phone,
        address: donor.address,
        cycle: selectedCycle || defaultCycle
      });

      // 2) Load Razorpay and open checkout
      const Razorpay = await loadRazorpayScript();
      const options = {
        key: 'rzp_live_RhWOsPuVUOT0Xx', // LIVE key - hardcoded
        subscription_id: data.subscriptionId,
        name: 'The One Rupee Revolution',
        description: `Recurring donation of ₹${activeAmount} ${selectedCycle || defaultCycle}`,
        handler: async function (response) {
          try {
            // Payment successful
            setSubmitted(true);
            setSubmitting(false);
            // Subscription is activated, webhook will handle status updates
          } catch (error) {
            console.error('Payment verification error:', error);
            setSubmitting(false);
            alert('Payment was successful but there was an error processing it. Please contact support.');
          }
        },
        prefill: {
          name: donor.name,
          email: donor.email,
          contact: donor.phone || ''
        },
        theme: {
          color: '#F97316'
        },
        modal: {
          ondismiss: function() {
            // User closed the payment modal
            setSubmitting(false);
          }
        },
        config: {
          display: {
            blocks: {
              banks: {
                name: 'All payment methods',
                instruments: [
                  {
                    method: 'upi'
                  },
                  {
                    method: 'card'
                  },
                  {
                    method: 'netbanking'
                  },
                  {
                    method: 'wallet'
                  }
                ]
              }
            },
            sequence: ['block.banks'],
            preferences: {
              show_default_blocks: true
            }
          }
        }
      };
      
      const razorpayInstance = new Razorpay(options);
      
      // Handle payment errors
      razorpayInstance.on('payment.failed', function (response) {
        console.error('Payment failed:', response.error);
        setSubmitting(false);
        const errorMsg = response.error?.description || response.error?.reason || 'Payment processing failed';
        alert(`Payment failed: ${errorMsg}\n\nPlease try again or contact support if the issue persists.`);
      });
      
      // Handle subscription authorization
      razorpayInstance.on('subscription.authorized', function (response) {
        console.log('Subscription authorized:', response);
      });
      
      razorpayInstance.on('subscription.charged', function (response) {
        console.log('Subscription charged:', response);
        setSubmitted(true);
        setSubmitting(false);
      });
      
      razorpayInstance.open();
    } catch (err) {
      // eslint-disable-next-line no-console
      console.error('Donation error', err);
      alert(err.response?.data?.error || 'Failed to create subscription. Please try again.');
      setSubmitting(false);
    }
  };

  // Dynamic content from site settings
  const [siteSettings, setSiteSettings] = useState({});
  useEffect(() => {
    const fetchSettings = async () => {
      try {
        const res = await publicAPI.getSiteSettings();
        setSiteSettings(res.data || {});
      } catch (err) {
        // no-op; fallbacks will render
      }
    };
    fetchSettings();
  }, []);

  const resolveSetting = (key) => {
    const direct = siteSettings?.[key]?.value;
    if (direct !== undefined && direct !== null && direct !== '') return direct;
    const aliases = {
      donate_image_url: ['Donate', 'donateImage', 'donate_image'],
      donate_image_alt: ['donateImageAlt', 'donate_alt'],
      donate_title: ['donateTitle', 'DonateTitle'],
      donate_subtitle: ['donateSubtitle', 'DonateSubtitle'],
      donate_content: ['donateContent', 'DonateContent']
    };
    for (const alt of (aliases[key] || [])) {
      const v = siteSettings?.[alt]?.value;
      if (v !== undefined && v !== null && v !== '') return v;
    }
    return undefined;
  };

  const getSetting = (key, fallback = '') => {
    const v = resolveSetting(key);
    if (typeof v === 'string') return v.trim() || fallback;
    return v ?? fallback;
  };

  const donateContentLines = (getSetting('donate_content', 'Some content\nSome content\nSome content'))
    .split('\n')
    .filter(Boolean);

  return (
    <div className="min-h-screen bg-gradient-to-b from-white via-primary-50/40 to-white">
      {/* Page Banner */}
      <PageBanner
        title="Donate Now"
        subtitle="Make a Difference Today"
        description="Your contribution, no matter how small, can create lasting change. Join the One Rupee Revolution and help us transform communities worldwide."
        variant="brown"
      />
      
      <div className="container mx-auto max-w-6xl px-4 py-10 md:py-14 lg:py-16">
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-12 items-start">
          {/* Image and content */}
          <div>
            <div className="w-full max-w-2xl aspect-[4/3] rounded-[28px] bg-primary-900/10 mx-auto lg:mx-0 flex items-center justify-center text-white shadow-xl ring-1 ring-black/5 overflow-hidden">
              {getSetting('donate_image_url', '') ? (
                <img
                  src={getSetting('donate_image_url', '')}
                  alt={getSetting('donate_image_alt', 'Donation')}
                  className="w-full h-full object-cover"
                  onError={(e) => { e.currentTarget.style.display = 'none'; }}
                />
              ) : (
                <span className="font-semibold tracking-wider text-primary-900/70">IMAGE</span>
              )}
            </div>

            <div className="mt-6 space-y-3 text-gray-800 leading-relaxed">
              {donateContentLines.map((line, idx) => (
                <p key={idx} className="text-base md:text-lg">{line}</p>
              ))}
            </div>
          </div>

          {/* Donation form card */}
          <div className="bg-white/95 backdrop-blur rounded-[32px] shadow-2xl p-6 md:p-8 border border-gray-100">
            <h2 className="text-center text-2xl md:text-3xl font-extrabold text-gray-900 tracking-tight mb-2">
              {getSetting('donate_title', 'Support the One Rupee Revolution')}
            </h2>
            {getSetting('donate_subtitle', '') && (
              <p className="text-center text-gray-600 mb-6">{getSetting('donate_subtitle', '')}</p>
            )}

            <form onSubmit={handleSubmit} className="grid grid-cols-1 gap-8">
            {/* Cycle Selection */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Select cycle</h3>
              <div className="flex flex-wrap gap-3">
                {['weekly', 'monthly', 'yearly'].map((c) => (
                  <button
                    type="button"
                    key={c}
                    onClick={async () => {
                      setCycle(c);
                      setCustomAmount(''); // Clear custom amount when cycle is selected
                      
                      // Update user details in database when cycle is selected
                      if (donor.name && donor.email) {
                        try {
                          await publicAPI.updateUserDetails({
                            name: donor.name,
                            email: donor.email,
                            phone: donor.phone,
                            address: donor.address,
                            cycle: c
                          });
                        } catch (error) {
                          console.error('Failed to update user details:', error);
                        }
                      }
                    }}
                    disabled={customAmount !== ''}
                    className={`px-4 py-2 rounded-full border text-sm font-semibold transition-colors capitalize ${
                      customAmount !== ''
                        ? 'bg-gray-100 text-gray-400 border-gray-200 cursor-not-allowed'
                        : cycle === c
                        ? 'bg-accent-500 text-white border-accent-500'
                        : 'bg-white text-gray-800 border-gray-300 hover:bg-primary-50'
                    }`}
                  >
                    {c.charAt(0).toUpperCase() + c.slice(1)}
                  </button>
                ))}
              </div>
            </div>

            {/* Amount Selection */}
            <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Enter Other Amount</h3>
              <div className="relative">
                <span className="absolute inset-y-0 left-3 flex items-center text-gray-500">₹</span>
                <input
                  type="number"
                  min="1"
                  value={customAmount}
                  onChange={(e) => {
                    const val = e.target.value;
                    setCustomAmount(val);
                  }}
                  className="w-full pl-7 pr-3 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 shadow-sm"
                  placeholder="Enter amount"
                />
              </div>
              <p className="text-xs text-gray-500 mt-2">Selected: ₹{activeAmount || '0'}</p>
            </div>

              {/* Donor Details */}
              <div>
              <h3 className="text-lg font-semibold text-gray-900 mb-3">Donor Details</h3>
              <div className="grid grid-cols-1 gap-4">
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Full Name *</label>
                  <input
                    type="text"
                    name="name"
                    value={donor.name}
                    onChange={handleDonorChange}
                    required
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 shadow-sm"
                    placeholder="Your name"
                  />
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Email *</label>
                  <input
                    type="email"
                    name="email"
                    value={donor.email}
                    onChange={handleDonorChange}
                    required
                    className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 shadow-sm ${
                      errors.email ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="you@example.com"
                  />
                  {errors.email && (
                    <p className="text-xs text-red-500 mt-1">{errors.email}</p>
                  )}
                  {validatingEmail && !errors.email && (
                    <p className="text-xs text-gray-500 mt-1">Checking email...</p>
                  )}
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Phone</label>
                  <input
                    type="tel"
                    name="phone"
                    value={donor.phone}
                    onChange={handleDonorChange}
                    className={`w-full px-4 py-3 border rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 shadow-sm ${
                      errors.phone ? 'border-red-500' : 'border-gray-300'
                    }`}
                    placeholder="+91-9876543210 or 9876543210"
                  />
                  {errors.phone && (
                    <p className="text-xs text-red-500 mt-1">{errors.phone}</p>
                  )}
                </div>
                <div>
                  <label className="block text-sm font-medium text-gray-700 mb-1">Address</label>
                  <input
                    type="text"
                    name="address"
                    value={donor.address}
                    onChange={handleDonorChange}
                    className="w-full px-4 py-3 border border-gray-300 rounded-xl focus:ring-2 focus:ring-primary-500 focus:border-primary-500 shadow-sm"
                    placeholder="Street, City, State"
                  />
                </div>
              </div>

              <div className="mt-6 flex items-center justify-between">
                <div className="text-gray-600 text-sm">
                  Total Donation: <span className="font-semibold text-gray-900">₹{activeAmount || '0'}</span>
                  {customAmount === '' && cycle && (
                    <span className="text-xs text-gray-500 ml-2">({cycle.charAt(0).toUpperCase() + cycle.slice(1)})</span>
                  )}
                </div>
                <button
                  type="submit"
                  disabled={submitting}
                  className="bg-accent-500 hover:bg-accent-600 disabled:opacity-70 text-white font-semibold px-7 py-3 rounded-full shadow-lg hover:shadow-xl transform hover:scale-105 transition-all duration-200"
                >
                  {submitting ? 'Processing...' : 'Donate Now'}
                </button>
              </div>
              </div>
            </form>

            {submitted && (
              <div className="mt-8 p-4 rounded-lg bg-green-50 border border-green-200 text-green-800">
                Thank you! Your donation was successful.
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
};

export default Donate;