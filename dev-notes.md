# Development Notes

## Quick Start Commands

```bash
# Enter development environment
nix develop

# Run all validation
just validate

# Build all configurations
just build-all

# Format code
just format

# Run security audit
just security-audit
```

## Development Workflow

1. Make changes to configurations
2. Run `just validate` to check syntax and security
3. Test builds with `just test-configs`
4. Format code with `just format`
5. Commit changes (pre-commit hooks will run automatically)

## Testing

- `just test-all` - Run comprehensive tests
- `just test-configs` - Test configuration builds
- `just test-packages` - Test package builds

## Deployment

- `just deploy <hostname>` - Deploy to remote host
- Local testing with VM images

## Troubleshooting

- Check logs in `logs/` directory
- Run `just system-info` for environment details
- Use `nix develop --command bash` for debugging
