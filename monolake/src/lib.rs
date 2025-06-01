//! MonoLake - High Performance Proxy
//! 
//! This library provides the core functionality for MonoLake HTTP proxy,
//! including socket handling, upstream management, and configuration.

pub mod config;
pub mod context;
pub mod factory;
pub mod util;

// Re-export commonly used types and functions
pub use factory::*;
pub use context::*; 